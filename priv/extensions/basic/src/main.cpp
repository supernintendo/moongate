/* port.c */
#include <erl_comm.h>

int main() {
  int fn, arg, res;
  byte buf[100];

  while (read_cmd(buf) > 0) {
    fn = buf[0];
    arg = buf[1];

    if (fn == 1) {
      res = 1;
    } else if (fn == 2) {
      res = 2;
    }

    buf[0] = res;
    write_cmd(buf, 1);
  }
}
