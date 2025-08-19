#!/usr/bin/env python3
import argparse
import yaml
from dataclasses import dataclass
from typing import Any, Dict, List


# Domain model
@dataclass
class Receipt:
    date_received: str
    rent_period: str
    amount: Any  # Could be str or numeric, depending on your yaml
    tenant_name: str
    property_address: str
    note: str
    landlord_name: str


# Function to parse receipts data from the data YAML.
def create_receipts(data: Dict[str, Any]) -> List[Receipt]:
    """
    Takes the parsed data YAML and returns a list of Receipt instances based on the rents list.
    """
    tenant = data.get("tenant", "")
    property_address = data.get("property", "")
    landlord = data.get("landlord", "")
    amount = data.get("amount", "")
    note = data.get("note", "")
    rents = data.get("rents", [])

    receipts: List[Receipt] = []
    for rent in rents:
        receipt = Receipt(
            date_received=rent.get("received", ""),
            rent_period=rent.get("period", ""),
            amount=amount,
            tenant_name=tenant,
            property_address=property_address,
            note=note,
            landlord_name=landlord,
        )
        receipts.append(receipt)
    return receipts


# Function to render a single receipt using the receipt_block template.
def render_receipt(receipt: Receipt, receipt_template: str) -> str:
    """
    Returns an HTML string for a single receipt by replacing placeholders in the receipt template.
    A note placeholder is conditionally rendered.
    """
    note_block = (
        f'<span class="filled-text">{receipt.note}</span>' if receipt.note else ""
    )

    # Prepare a dictionary for formatting the receipt template.
    # Ensure that the keys in the template match these names.
    formatted_receipt = receipt_template.format(
        date_received=receipt.date_received,
        rent_period=receipt.rent_period,
        amount=receipt.amount,
        tenant_name=receipt.tenant_name,
        property_address=receipt.property_address,
        landlord_name=receipt.landlord_name,
        note_block=note_block,
    )
    return formatted_receipt


# Function to generate the full receipts HTML, inserting page breaks every 3 receipts.
def generate_receipts_html(receipts: List[Receipt], receipt_template: str) -> str:
    """
    Concatenates the rendered receipts. Every three receipts, a page break is inserted.
    """
    receipts_html = ""
    for index, receipt in enumerate(receipts):
        if index % 3 == 0:
            receipts_html += '    <div class="page-container">'
        receipts_html += render_receipt(receipt, receipt_template)
        # If the (index+1) is divisible by 3 and not the last receipt, insert a page break.
        if (index + 1) % 3 == 0 and index < len(receipts) - 1:
            receipts_html += '<div class="page-break"></div>'
            receipts_html += "    </div>"
    return receipts_html


# Function to build the final HTML using the page template.
def build_final_html(page_template: str, receipts_html: str) -> str:
    """
    Inserts the concatenated receipts HTML into the page template.
    """
    # Assumes the placeholder in page template is named 'receipts'
    return page_template.format(receipts=receipts_html)


# Main function to parse arguments and generate HTML.
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate HTML receipt pages from YAML inputs."
    )
    parser.add_argument(
        "--template",
        type=argparse.FileType("r"),
        required=True,
        help="Path to the YAML file containing the template definitions.",
    )
    parser.add_argument(
        "--data",
        type=argparse.FileType("r"),
        required=True,
        help="Path to the YAML file containing the receipt data.",
    )
    parser.add_argument(
        "--output", type=argparse.FileType("w"), required=False, help="File to save"
    )

    args = parser.parse_args()

    # Load YAML files
    try:
        template_yaml = yaml.safe_load(args.template)
        data_yaml = yaml.safe_load(args.data)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        return

    # Extract the required templates:
    try:
        page_template = template_yaml["template"]["page"]
        receipt_template = template_yaml["template"]["receipt_block"]
    except KeyError as e:
        print(f"Template key missing: {e}")
        return

    # Create a list of Receipt instances from the data YAML.
    receipts = create_receipts(data_yaml)

    # Generate receipt HTML.
    receipts_html = generate_receipts_html(receipts, receipt_template)

    # Build the final HTML by placing the receipts HTML inside the page template.
    final_html = build_final_html(page_template, receipts_html)

    # Output the final HTML to stdout.
    if args.output is not None:
        args.output.write(final_html)
    else:
        print(final_html)


if __name__ == "__main__":
    main()
