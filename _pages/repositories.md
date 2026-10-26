---
layout: default
title: Repositories
permalink: /repositories/
---

<div class="repositories">
{% for repository in site.data.repositories %}
  <article class="repository">
    <a href="{{ repository.url | escape }}" class="repository-title">{% include icon.html name='github' %}<span>{{ repository.name | escape }}</span></a>
    <p class="muted">{{ repository.owner | escape }}</p>
  </article>
{% endfor %}
</div>
