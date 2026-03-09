#!/usr/bin/env python3
"""
generate_diagram.py
-------------------
Reads an observability architecture YAML config and renders a PNG diagram.

Usage:
    python3 generate_diagram.py                            # uses observability_config.yaml
    python3 generate_diagram.py my_config.yaml            # custom config
    python3 generate_diagram.py my_config.yaml out.png    # custom config + output path
"""

import sys
import os
import argparse
import textwrap
import yaml
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

# ─────────────────────────────────────────────────────────────────────────────
# Named colour palette
# ─────────────────────────────────────────────────────────────────────────────
PALETTE = {
    'bg':     '#0B1628',
    'panel':  '#142038',
    'card':   '#1A2C47',
    'border': '#1E3A5F',
    'teal':   '#0D9488',
    'blue':   '#3B82F6',
    'amber':  '#F59E0B',
    'purple': '#8B5CF6',
    'rose':   '#F43F5E',
    'green':  '#10B981',
    'cyan':   '#06B6D4',
    'white':  '#FFFFFF',
    'muted':  '#94A3B8',
    'light':  '#CBD5E1',
    'arrow':  '#2A4A6B',
}

def resolve_color(key):
    """Return a hex string for a palette key or pass-through a raw hex."""
    if key is None:
        return PALETTE['white']
    if key.startswith('#'):
        return key
    return PALETTE.get(key, PALETTE['white'])


# ─────────────────────────────────────────────────────────────────────────────
# Low-level drawing helpers
# ─────────────────────────────────────────────────────────────────────────────
def rbox(ax, x, y, w, h, fc, ec, lw=1.2, radius=0.25, zorder=2):
    patch = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0,rounding_size={radius}",
        facecolor=fc, edgecolor=ec, linewidth=lw, zorder=zorder
    )
    ax.add_patch(patch)


def txt(ax, x, y, text, size, color, weight='normal', ha='center', va='center',
        style='normal', ls=1.2, zorder=5):
    ax.text(
        x, y, text,
        fontsize=size, color=color, fontweight=weight,
        ha=ha, va=va, style=style, linespacing=ls,
        family='DejaVu Sans', zorder=zorder
    )


def arrow_down(ax, x, y_start, y_end, color, lw=1.8):
    ax.annotate(
        '', xy=(x, y_end), xytext=(x, y_start),
        arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                        connectionstyle='arc3,rad=0.0'),
        zorder=1
    )


def arrow_lr(ax, x_start, x_end, y, color, lw=1.8, style='<->'):
    ax.annotate(
        '', xy=(x_end, y), xytext=(x_start, y),
        arrowprops=dict(arrowstyle=style, color=color, lw=lw,
                        connectionstyle='arc3,rad=0.0'),
        zorder=5
    )


def dashed_arrow_up(ax, x, y_start, y_end, color, lw=1.4):
    ax.annotate(
        '', xy=(x, y_end), xytext=(x, y_start),
        arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                        linestyle='dashed', connectionstyle='arc3,rad=0.0'),
        zorder=1
    )


def small_arrow_right(ax, x_start, x_end, y, color, lw=1.2):
    ax.annotate(
        '', xy=(x_end, y), xytext=(x_start, y),
        arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                        connectionstyle='arc3,rad=0.0'),
        zorder=5
    )


# ─────────────────────────────────────────────────────────────────────────────
# Section renderers
# ─────────────────────────────────────────────────────────────────────────────
def draw_title(ax, cfg):
    t = cfg.get('title', {})
    txt(ax, 10, 12.55, t.get('main', ''), 15, PALETTE['white'], weight='bold')
    txt(ax, 10, 12.18, t.get('subtitle', ''), 8.5, PALETTE['muted'])
    ax.plot([1.5, 18.5], [12.0, 12.0], color=PALETTE['teal'], lw=1.5, zorder=3)


def draw_data_sources(ax, cfg):
    ds = cfg.get('data_sources', {})
    items = ds.get('items', [])
    n = len(items)
    if n == 0:
        return

    src_y, src_h, src_gap = 10.7, 1.05, 0.20
    src_w = (18.0 - (n - 1) * src_gap) / n
    src_x0 = 1.0

    # Background panel
    rbox(ax, 0.6, src_y - 0.18, 18.8, src_h + 0.54,
         PALETTE['panel'], PALETTE['border'], lw=0.8, radius=0.3, zorder=1)
    txt(ax, 0.98, src_y + src_h + 0.18,
        ds.get('section_label', 'DATA SOURCES'),
        7.5, PALETTE['muted'], weight='bold', ha='left', zorder=4)

    for i, item in enumerate(items):
        color = resolve_color(item.get('color', 'white'))
        sx = src_x0 + i * (src_w + src_gap)

        rbox(ax, sx, src_y, src_w, src_h, PALETTE['card'], color, lw=1.5, radius=0.2, zorder=3)
        # Top accent bar
        rbox(ax, sx, src_y + src_h - 0.07, src_w, 0.07, color, color,
             radius=0.12, zorder=4)
        txt(ax, sx + src_w / 2, src_y + src_h - 0.26,
            item.get('name', ''), 9, PALETTE['white'], weight='bold', zorder=5)

        for li, line in enumerate(item.get('details', [])[:3]):
            txt(ax, sx + src_w / 2, src_y + src_h - 0.54 - li * 0.20,
                line, 6.2, PALETTE['muted'], zorder=5)

    return src_y, src_h, src_gap, src_w, src_x0, n


def draw_pipeline(ax, cfg, src_y, n_sources, src_w, src_gap, src_x0):
    pipe_cfg = cfg.get('pipeline', {})
    stages = pipe_cfg.get('stages', [])
    pipe_y, pipe_h = 9.0, 1.05

    # Arrows from each source card down into the pipeline band
    for i in range(n_sources):
        sx = src_x0 + i * (src_w + src_gap) + src_w / 2
        arrow_down(ax, sx, src_y, pipe_y + pipe_h, PALETTE['arrow'], lw=1.4)

    # Pipeline band
    rbox(ax, 0.6, pipe_y, 18.8, pipe_h, PALETTE['panel'], PALETTE['teal'],
         lw=1.2, radius=0.25, zorder=2)
    rbox(ax, 0.6, pipe_y, 0.1, pipe_h, PALETTE['teal'], PALETTE['teal'],
         radius=0.1, zorder=3)

    txt(ax, 10, pipe_y + 0.72, pipe_cfg.get('label', 'DATA PIPELINE'),
        9, PALETTE['teal'], weight='bold', zorder=4)
    txt(ax, 10, pipe_y + 0.82,
        pipe_cfg.get('tech_note', ''),
        6.8, PALETTE['muted'], style='italic', zorder=4)

    # Stage pills
    n = len(stages)
    step_w, step_h, step_gap = 2.8, 0.36, 0.22
    total_w = n * step_w + (n - 1) * step_gap
    step_x0 = (20 - total_w) / 2

    for i, stage in enumerate(stages):
        color = resolve_color(stage.get('color', 'teal'))
        sx = step_x0 + i * (step_w + step_gap)
        rbox(ax, sx, pipe_y + 0.12, step_w, step_h,
             color + '33', color, lw=1.0, radius=0.12, zorder=4)
        txt(ax, sx + step_w / 2, pipe_y + 0.30,
            stage.get('name', ''), 7.5, PALETTE['white'], weight='bold', zorder=5)
        if i < n - 1:
            small_arrow_right(ax, sx + step_w, sx + step_w + step_gap,
                               pipe_y + 0.30, PALETTE['muted'])

    return pipe_y, pipe_h


def draw_analytics(ax, cfg, pipe_y):
    core_y, core_h = 6.2, 2.65

    # Arrow pipeline → analytics
    arrow_down(ax, 10, pipe_y, core_y + core_h, PALETTE['teal'], lw=2.0)

    # ── Elasticsearch ────────────────────────────────────────────────────────
    es_cfg = cfg.get('elasticsearch', {})
    es_x, es_w = 0.6, 11.2
    es_color = resolve_color(es_cfg.get('border_color', 'teal'))

    rbox(ax, es_x, core_y, es_w, core_h, PALETTE['card'], es_color, lw=1.5, radius=0.28, zorder=2)
    rbox(ax, es_x, core_y + core_h - 0.08, es_w, 0.08, es_color, es_color,
         radius=0.18, zorder=3)
    txt(ax, es_x + es_w / 2, core_y + core_h - 0.28,
        es_cfg.get('title', 'ELASTICSEARCH OBSERVABILITY'),
        10, PALETTE['white'], weight='bold', zorder=6)
    txt(ax, es_x + es_w / 2, core_y + core_h - 0.52,
        es_cfg.get('subtitle', ''), 6.8, es_color, style='italic', zorder=6)

    # 3×3 capability grid — row 0 = top (y highest), row 2 = bottom
    cap_row_y = [core_y + 1.55, core_y + 0.95, core_y + 0.38]
    cap_col_x = [es_x + 0.80,   es_x + 4.00,   es_x + 7.30]
    cap_w, cap_h = 2.8, 0.42

    for cap in es_cfg.get('capabilities', []):
        r = cap.get('row', 0)
        c = cap.get('col', 0)
        if r > 2 or c > 2:
            continue
        cx, cy = cap_col_x[c], cap_row_y[r]
        color = resolve_color(cap.get('color', 'teal'))
        rbox(ax, cx, cy, cap_w, cap_h, color + '22', color, lw=0.8, radius=0.12, zorder=4)
        txt(ax, cx + cap_w / 2, cy + cap_h / 2,
            cap.get('name', ''), 7, PALETTE['white'], weight='bold', zorder=5)

    # ── Grafana ───────────────────────────────────────────────────────────────
    gr_cfg = cfg.get('grafana', {})
    gr_x, gr_w = 12.2, 7.2
    gr_color = resolve_color(gr_cfg.get('border_color', 'amber'))

    rbox(ax, gr_x, core_y, gr_w, core_h, PALETTE['card'], gr_color, lw=1.5, radius=0.28, zorder=2)
    rbox(ax, gr_x, core_y + core_h - 0.08, gr_w, 0.08, gr_color, gr_color,
         radius=0.18, zorder=3)
    txt(ax, gr_x + gr_w / 2, core_y + core_h - 0.30,
        gr_cfg.get('title', 'GRAFANA'), 10, PALETTE['white'], weight='bold', zorder=4)
    txt(ax, gr_x + gr_w / 2, core_y + core_h - 0.56,
        gr_cfg.get('subtitle', ''), 7, gr_color, style='italic', zorder=4)

    gr_caps = gr_cfg.get('capabilities', [])
    n_gc = len(gr_caps)
    gc_w, gc_h = 2.0, 0.60
    gc_gap = 0.25
    gc_total = n_gc * gc_w + (n_gc - 1) * gc_gap
    gc_x0 = gr_x + (gr_w - gc_total) / 2

    for i, cap in enumerate(gr_caps):
        color = resolve_color(cap.get('color', 'amber'))
        cx = gc_x0 + i * (gc_w + gc_gap)
        rbox(ax, cx, core_y + 0.90, gc_w, gc_h, color + '22', color,
             lw=0.8, radius=0.12, zorder=4)
        txt(ax, cx + gc_w / 2, core_y + 0.90 + gc_h / 2,
            cap.get('name', ''), 7, PALETTE['white'], weight='bold', zorder=5, ls=1.5)

    txt(ax, gr_x + gr_w / 2, core_y + 0.38,
        gr_cfg.get('data_sources_note', ''), 6.5, PALETTE['muted'], zorder=4, ls=1.5)

    # Bidirectional arrow ES ↔ Grafana
    arrow_lr(ax, es_x + es_w, gr_x, core_y + core_h / 2, gr_color, lw=1.8)

    return core_y, core_h


def draw_api(ax, cfg, core_y):
    api_cfg = cfg.get('api_services', {})
    items = api_cfg.get('items', [])
    api_y, api_h = 5.10, 1.05
    api_color = resolve_color(api_cfg.get('border_color', 'blue'))

    arrow_down(ax, 10, core_y, api_y + api_h, PALETTE['arrow'], lw=1.8)

    rbox(ax, 0.6, api_y, 18.8, api_h, PALETTE['panel'], api_color,
         lw=1.2, radius=0.25, zorder=2)
    rbox(ax, 0.6, api_y, 0.1, api_h, api_color, api_color,
         radius=0.1, zorder=3)
    txt(ax, 10, api_y + 0.72,
        api_cfg.get('label', 'API SERVICES'), 9, api_color, weight='bold', zorder=4)

    n = len(items)
    api_w, api_gap = 3.0, 0.26
    total = n * api_w + (n - 1) * api_gap
    ax0 = (20 - total) / 2

    for i, item in enumerate(items):
        color = resolve_color(item.get('color', 'blue'))
        ix = ax0 + i * (api_w + api_gap)
        rbox(ax, ix, api_y + 0.12, api_w, 0.38, color + '25', color,
             lw=0.9, radius=0.12, zorder=4)
        txt(ax, ix + api_w / 2, api_y + 0.32,
            item.get('name', ''), 7.5, PALETTE['white'], weight='bold', zorder=5)

    return api_y, api_h


def draw_consume(ax, cfg, api_y):
    low_y, low_h = 2.60, 2.15

    # ── External Integrations ─────────────────────────────────────────────────
    ei_cfg = cfg.get('external_integrations', {})
    ei_x, ei_w = 0.6, 8.8
    ei_color = resolve_color(ei_cfg.get('border_color', 'rose'))

    arrow_down(ax, 5.0, api_y, low_y + low_h, PALETTE['arrow'], lw=1.6)

    rbox(ax, ei_x, low_y, ei_w, low_h, PALETTE['card'], ei_color, lw=1.5, radius=0.28, zorder=2)
    rbox(ax, ei_x, low_y + low_h - 0.08, ei_w, 0.08, ei_color, ei_color,
         radius=0.18, zorder=3)
    txt(ax, ei_x + ei_w / 2, low_y + low_h - 0.30,
        ei_cfg.get('title', 'EXTERNAL INTEGRATIONS'),
        10, PALETTE['white'], weight='bold', zorder=4)
    txt(ax, ei_x + ei_w / 2, low_y + low_h - 0.56,
        ei_cfg.get('subtitle', ''), 7, ei_color, style='italic', zorder=4)

    # Capability grid: row 0 = bottom row, row 1 = top row
    ei_row_y = [low_y + 0.10, low_y + 0.80]
    ei_col_x = [ei_x + 0.625, ei_x + 3.225, ei_x + 5.825]
    cap_w, cap_h = 2.35, 0.62

    for cap in ei_cfg.get('capabilities', []):
        r = cap.get('row', 0)
        c = cap.get('col', 0)
        if r > 1 or c > 2:
            continue
        cx, cy = ei_col_x[c], ei_row_y[r]
        color = resolve_color(cap.get('color', 'rose'))
        rbox(ax, cx, cy, cap_w, cap_h, color + '22', color, lw=0.8, radius=0.12, zorder=4)
        txt(ax, cx + cap_w / 2, cy + cap_h / 2,
            cap.get('name', ''), 6.8, PALETTE['white'], weight='bold', zorder=5, ls=1.5)

    # ── AI Agents ─────────────────────────────────────────────────────────────
    ai_cfg = cfg.get('ai_agents', {})
    ai_x, ai_w = 10.6, 8.8
    ai_color = resolve_color(ai_cfg.get('border_color', 'purple'))

    arrow_down(ax, 15.0, api_y, low_y + low_h, PALETTE['arrow'], lw=1.6)

    rbox(ax, ai_x, low_y, ai_w, low_h, PALETTE['card'], ai_color, lw=1.5, radius=0.28, zorder=2)
    rbox(ax, ai_x, low_y + low_h - 0.08, ai_w, 0.08, ai_color, ai_color,
         radius=0.18, zorder=3)
    txt(ax, ai_x + ai_w / 2, low_y + low_h - 0.30,
        ai_cfg.get('title', 'SRE AGENT & AI AGENTS'),
        10, PALETTE['white'], weight='bold', zorder=4)
    txt(ax, ai_x + ai_w / 2, low_y + low_h - 0.56,
        ai_cfg.get('subtitle', ''), 7, ai_color, style='italic', zorder=4)

    # MCP badge (sits between the two panels)
    rbox(ax, 9.42, low_y + 1.00, 1.16, 0.56,
         ai_color + '33', ai_color, lw=1.4, radius=0.14, zorder=5)
    txt(ax, 10.0, low_y + 1.32, ai_cfg.get('mcp_label', 'MCP'),
        9, ai_color, weight='bold', zorder=6)
    txt(ax, 10.0, low_y + 1.11, ai_cfg.get('mcp_sublabel', 'Protocol'),
        6.2, PALETTE['muted'], zorder=6)

    # Capability grid: row 0 = bottom, row 1 = top
    ai_row_y = [low_y + 0.10, low_y + 0.80]
    ai_col_x = [ai_x + 0.625, ai_x + 3.225, ai_x + 5.825]

    for cap in ai_cfg.get('capabilities', []):
        r = cap.get('row', 0)
        c = cap.get('col', 0)
        if r > 1 or c > 2:
            continue
        cx, cy = ai_col_x[c], ai_row_y[r]
        color = resolve_color(cap.get('color', 'purple'))
        rbox(ax, cx, cy, cap_w, cap_h, color + '22', color, lw=0.8, radius=0.12, zorder=4)
        txt(ax, cx + cap_w / 2, cy + cap_h / 2,
            cap.get('name', ''), 6.8, PALETTE['white'], weight='bold', zorder=5, ls=1.5)

    # Dashed arrow: agents → API (MCP access upward)
    dashed_arrow_up(ax, ai_x + ai_w / 2, low_y + low_h, api_y, ai_color, lw=1.4)

    return low_y, low_h


def draw_footer(ax, cfg, low_y):
    footer = cfg.get('footer', {})
    ax.plot([0.6, 19.4], [2.45, 2.45], color=PALETTE['border'], lw=0.8, zorder=1)

    fx = 1.2
    for item in footer.get('legend', []):
        color = resolve_color(item.get('color', 'white'))
        ax.text(fx, 2.18, item.get('text', ''), fontsize=7, color=color,
                ha='left', va='center', zorder=5, family='DejaVu Sans')
        fx += 3.6

    txt(ax, 10, 1.72, footer.get('note', ''), 7.5, PALETTE['muted'])


def draw_layer_labels(ax, cfg, src_y, src_h, pipe_y, pipe_h,
                      core_y, core_h, api_y, api_h, low_y, low_h):
    ll = cfg.get('layer_labels', {})
    layers = [
        (src_y + src_h / 2 + 0.18,  PALETTE['teal'],  ll.get('ingest',    'INGEST')),
        (pipe_y + pipe_h / 2,        PALETTE['teal'],  ll.get('pipeline',  'PIPELINE')),
        (core_y + core_h / 2,        PALETTE['white'], ll.get('analytics', 'ANALYTICS')),
        (api_y + api_h / 2,          PALETTE['blue'],  ll.get('api',       'API')),
        (low_y + low_h / 2,          PALETTE['muted'], ll.get('consume',   'CONSUME')),
    ]
    for ly, color, label in layers:
        ax.text(0.18, ly, label, fontsize=6.5, color=color,
                ha='center', va='center', rotation=90,
                fontweight='bold', family='DejaVu Sans', zorder=5)



# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
def generate(config_path, output_override=None, dpi_override=None, fmt_override=None):
    with open(config_path, 'r') as f:
        cfg = yaml.safe_load(f)

    out_cfg  = cfg.get('output', {})
    out_file = output_override or out_cfg.get('file', 'observability-architecture.png')
    dpi      = dpi_override or int(out_cfg.get('dpi', 200))

    # Determine format: explicit flag > file extension > default png
    if fmt_override:
        fmt = fmt_override.lower().lstrip('.')
    else:
        ext = os.path.splitext(out_file)[1].lower().lstrip('.')
        fmt = ext if ext in ('png', 'svg') else 'png'

    # Ensure the file extension matches the chosen format
    base_name, current_ext = os.path.splitext(out_file)
    if current_ext.lower().lstrip('.') != fmt:
        out_file = f"{base_name}.{fmt}"

    # Canvas
    fig, ax = plt.subplots(figsize=(20, 13))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 13)
    ax.axis('off')
    fig.patch.set_facecolor(PALETTE['bg'])
    ax.set_facecolor(PALETTE['bg'])

    # Draw each section
    draw_title(ax, cfg)

    result = draw_data_sources(ax, cfg)
    if result is None:
        print("Warning: no data sources defined.")
        return
    src_y, src_h, src_gap, src_w, src_x0, n_sources = result

    pipe_y, pipe_h = draw_pipeline(ax, cfg, src_y, n_sources, src_w, src_gap, src_x0)
    core_y, core_h = draw_analytics(ax, cfg, pipe_y)
    api_y,  api_h  = draw_api(ax, cfg, core_y)
    low_y,  low_h  = draw_consume(ax, cfg, api_y)

    draw_footer(ax, cfg, low_y)
    draw_layer_labels(ax, cfg,
                      src_y, src_h, pipe_y, pipe_h,
                      core_y, core_h, api_y, api_h, low_y, low_h)

    plt.tight_layout(pad=0)
    save_kwargs = dict(bbox_inches='tight', facecolor=PALETTE['bg'], edgecolor='none')

    if fmt == 'svg':
        save_kwargs['format'] = 'svg'
        plt.savefig(out_file, **save_kwargs)
        size_kb = os.path.getsize(out_file) // 1024
        print(f"Saved: {out_file}  (SVG, vector, ~{size_kb} KB)")
    else:
        save_kwargs['dpi'] = dpi
        plt.savefig(out_file, **save_kwargs)
        size_kb = os.path.getsize(out_file) // 1024
        w_px = int(20 * dpi)
        h_px = int(13 * dpi)
        print(f"Saved: {out_file}  ({dpi} DPI, {w_px}x{h_px}px, ~{size_kb} KB)")

    plt.close(fig)


def build_parser():
    parser = argparse.ArgumentParser(
        prog='generate_diagram.py',
        description='Enterprise Observability Architecture Diagram Generator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""
EXAMPLES
  python3 generate_diagram.py
      Default: reads observability_config.yaml

  python3 generate_diagram.py my_config.yaml
      Custom config, output path taken from YAML

  python3 generate_diagram.py -o diagram.png -d 300
      PNG at 300 DPI (standard print quality)

  python3 generate_diagram.py -o diagram.svg
      SVG output (resolution-independent)

  python3 generate_diagram.py my_config.yaml -f svg -o arch.svg
      Custom config, force SVG format

  python3 generate_diagram.py -d 600 -o diagram-print.png
      Maximum PNG quality for large-format printing

DPI GUIDE  (PNG only, ignored for SVG)
  150   screen / web
  200   PowerPoint slides  [default]
  300   standard print quality
  600   large-format / high-quality print
        """)
    )
    parser.add_argument(
        'config',
        nargs='?',
        default='observability_config.yaml',
        metavar='CONFIG',
        help='Path to YAML config file  (default: observability_config.yaml)'
    )
    parser.add_argument(
        '-o', '--output',
        default=None,
        metavar='FILE',
        help='Output file path. Extension determines format (.png or .svg). '
             'Overrides output.file in the YAML.'
    )
    parser.add_argument(
        '-f', '--format',
        default=None,
        choices=['png', 'svg'],
        metavar='FORMAT',
        help='Force output format: png or svg  (default: inferred from -o extension)'
    )
    parser.add_argument(
        '-d', '--dpi',
        type=int,
        default=None,
        metavar='DPI',
        help='PNG resolution in dots-per-inch, ignored for SVG  (default: 200)'
    )
    return parser


if __name__ == '__main__':
    parser = build_parser()
    args   = parser.parse_args()

    if not os.path.exists(args.config):
        parser.error(f"Config file not found: {args.config}")

    generate(
        config_path     = args.config,
        output_override = args.output,
        dpi_override    = args.dpi,
        fmt_override    = args.format,
    )
