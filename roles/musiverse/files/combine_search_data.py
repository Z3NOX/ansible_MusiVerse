#!/usr/bin/env python3
import json
import hashlib
import argparse

p = argparse.ArgumentParser()
p.add_argument("--input", "-i", nargs="+", required=True, type=argparse.FileType('r'),
               help="input files normally called ’search-data.json’ originating from "
                    "different jekyll runs")
p.add_argument("--output", "-o", type=argparse.FileType('w'), default="search-data.json")

args = p.parse_args()

gather_dict = {}
maxentries = 0
for inputfile in args.input:
    with inputfile as file:
        searchdata = json.load(file)
    for key, value in searchdata.items():
        content_hash = hashlib.sha512(value["content"].encode("utf-8")).hexdigest()
        gather_dict[content_hash] = value

output_dict = {}
for i, key in enumerate(gather_dict):
    output_dict[i] = gather_dict[key]

with args.output as file:
    json.dump(output_dict, file)
