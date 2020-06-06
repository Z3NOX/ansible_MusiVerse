---
layout: default
title: Pakete
permalink: Pakete
nav_order: 1
has_children: true
has_toc: false

---

# Installierte Pakete
{% for item, value in packages.items() %}
{% if value.state == "present" %}
* [{{ value.name }}](./Pakete/{{ item }})
{% endif %}
{% endfor %}

