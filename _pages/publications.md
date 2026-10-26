---
layout: default
title: Publications
permalink: /publications/
---

<p class="muted">* Equal contribution</p>
{% assign papers_by_year = site.data.publications | group_by: 'year' | sort: 'name' | reverse %}
{% for year in papers_by_year %}
<section aria-labelledby="year-{{ year.name }}">
  <h2 id="year-{{ year.name }}" class="year-heading">{{ year.name }}</h2>
  {% include publications.html papers=year.items %}
</section>
{% endfor %}
