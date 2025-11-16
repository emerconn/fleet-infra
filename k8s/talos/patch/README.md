# How To Apply MachineConfig Patch

```bash
talosctl patch mc \
  --nodes cp-01.tal-clu-1.hl.emerconn.com,cp-02.tal-clu-1.hl.emerconn.com,cp-03.tal-clu-1.hl.emerconn.com,w-01.tal-clu-1.hl.emerconn.com \
  --patch @all.yaml
```