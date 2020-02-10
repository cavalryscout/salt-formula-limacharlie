{# limacharlie/init.sls #}

{% from "limacharlie/map.jinja" import limacharlie_settings with context %}

/bin/rphcp:
  file.managed:
    - source: {{ limacharlie_settings.lookup.sensor_url }}
    - skip_verify: True
    - user: root
    - group: root
    - mode: 0500

/etc/init.d/limacharlie:
  file.managed:
    - source: salt://limacharlie/files/etc/init.d/limacharlie
    - template: jinja
    - context:
      install_key: {{ limacharlie_settings.sensors.sensor.install_key }}
    - user: root
    - group: root
    - mode: 0500
    - require:
      - file: /bin/rphcp

systemctl-daemon-reload-limacharlie:
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - file: /bin/rphcp
      - file: /etc/init.d/limacharlie
    - onchanges:
      - file: /bin/rphcp
      - file: /etc/init.d/limacharlie

service-limacharlie:
  service.running:
    - name: limacharlie
    - enable: True
    - require:
      - cmd: systemctl-daemon-reload-limacharlie
    - watch:
      - cmd: systemctl-daemon-reload-limacharlie

{# EOF #}
