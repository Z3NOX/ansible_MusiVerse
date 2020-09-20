#!/usr/bin/env python3
"""
Open multiple json files with lunr search data to combine them into one file
"""


import json
import hashlib
import argparse

p = argparse.ArgumentParser()
p.add_argument("--input", "-i", nargs="+", required=True, type=argparse.FileType('r'),
               help="input files normally called ’search-data.json’ originating from "
                    "different jekyll runs")
p.add_argument("--output", "-o", type=argparse.FileType('w'), default="search-data.json")

args = p.parse_args()

# dict to gather/bin the search data based on a hash
# that symbolize the entries uniqueness
gather_dict = {}

# simple counter
maxentries = 0
for inputfile in args.input:
    with inputfile as file:
        searchdata = json.load(file)
    for key, value in searchdata.items():
        # hash over the "title" information
        content_hash = hashlib.sha512(value["title"].encode("utf-8")).hexdigest()
        gather_dict[content_hash] = value

output_dict = {}
for i, key in enumerate(gather_dict):
    output_dict[i] = gather_dict[key]

with args.output as file:
    json.dump(output_dict, file)
