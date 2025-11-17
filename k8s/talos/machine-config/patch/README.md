# How To Apply MachineConfig Patch

- Apply the MachineConfig patch to all nodes:

```bash
talosctl patch mc \
  --nodes cp-01.tal-clu-1.hl.emerconn.com,cp-02.tal-clu-1.hl.emerconn.com,cp-03.tal-clu-1.hl.emerconn.com,w-01.tal-clu-1.hl.emerconn.com \
  --patch @all.yaml
```

- If reboot is required, reboot all nodes one-by-one:

```bash
talosctl reboot --nodes cp-01.tal-clu-1.hl.emerconn.com
talosctl reboot --nodes cp-02.tal-clu-1.hl.emerconn.com
talosctl reboot --nodes cp-03.tal-clu-1.hl.emerconn.com
talosctl reboot --nodes w-01.tal-clu-1.hl.emerconn.com
```
