---
layout: default
title: About
permalink: /
---

<section class="home-hero" aria-labelledby="home-heading">
  <div class="hero-content">
    <h1 id="home-heading">{{ site.data.profile.display_name | escape }}</h1>
    <p class="hero-eyebrow">Top Skills:</p>
    <p class="hero-specialties">Machine Learning (ML), Computer Vision (CV), Image Compression, Multimodal Large Language Models (MLLM)</p>
    <a class="button button-primary hero-resume" href="{{ site.data.profile.cv_pdf | relative_url }}">CV / Resume <span aria-hidden="true">↓</span></a>
    {% include contact.html %}
  </div>
  <div class="hero-portrait">
    <img src="{{ site.data.profile.photo | relative_url }}" alt="Portrait of {{ site.data.profile.name | escape }}" width="665" height="720" fetchpriority="high">
  </div>
</section>

{% if site.data.cv.work.size > 0 %}
<section class="home-experience" aria-labelledby="home-experience-heading">
  <div class="section-heading">
    <h2 id="home-experience-heading">Work Experience</h2>
    <a class="section-link" href="{{ '/cv/' | relative_url }}#experience">View full experience <span aria-hidden="true">↗</span></a>
  </div>
  {% include experience.html entries=site.data.cv.work featured_only=true %}
</section>
{% endif %}

<section class="selected-publications" aria-labelledby="selected-heading">
  <div class="section-heading">
    <h2 id="selected-heading"><a href="{{ '/publications/' | relative_url }}">Selected Publications</a></h2>
    <a class="section-link" href="{{ '/publications/' | relative_url }}">Publications <span aria-hidden="true">↗</span></a>
  </div>
  {% assign selected_papers = site.data.publications | where: 'selected', true | group_by: 'year' | sort: 'name' | reverse %}
  {% for year in selected_papers %}{% include publications.html papers=year.items %}{% endfor %}
</section>

<section class="home-about" aria-labelledby="about-heading">
  <h2 id="about-heading">{{ page.title }}</h2>
  <div class="about-body" markdown="1">

My name is Chien Cheng, and I hold a Master’s degree in Computer Science from [National Yang Ming Chiao Tung University](https://www.nycu.edu.tw/nycu/en/). My master’s research focuses on machine learning, computer vision, image compression, and multimodal large language models (MLLM). My master’s thesis, titled “[ComNeck: Bridging Compressed Image Latents and Multimodal LLMs via Universal Transform-Neck](https://hdl.handle.net/20.500.14371/3093),” combines learning-base image compression with a multimodal language model. This work has been submitted to the international conference ICLR and is currently under review.

During my graduate studies, I participated in several National Science and Technology Council (NSTC) projects and collaborated with my lab members to publish research in top-tier international conferences such as ICCV, APSIPA ASC, and ISCAS. Through these experiences, I developed strong technical skills, cooperation, and communication abilities. I am proficient in Python and experienced in using PyTorch to build the machine learning model, with expertise in handling the entire workflow from data preprocessing to model training. Additionally, I studied in the Philippines for three months after graduation, where I demonstrated my adaptability to new environments and my capability to perform independently across different cultures and languages. This further strengthened my ability to communicate, coordinate, and resolve issues in English.

During my undergraduate studies, I maintained excellent academic performance, receiving multiple academic awards. At the same time, I served as the president of a student club, where I successfully organized large-scale events with over 100 participants. This role shows my strong ability on leadership, time management, and multitasking skills.

I earned my M.S. in Computer Science from National Yang Ming Chiao Tung University in 2024, under the guidance of [Prof. Wen-Hsiao Peng](https://sites.google.com/g2.nctu.edu.tw/wpeng/). Prior to this, I completed my B.S. in Computer Science and Engineering at [National Sun Yat-sen University](https://www.nsysu.edu.tw/?Lang=en) in 2022.

Feel free to reach out via [email](mailto:{{ site.data.profile.email }}) or connect with me on [LinkedIn]({{ site.data.profile.url }}).

  </div>
</section>
