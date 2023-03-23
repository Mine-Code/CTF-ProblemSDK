#include <stdlib.h>
#include <stdio.h>
#include <flag.h>

int main() {
  printf("Flag: %s\n", get_flag_from_env());
  return 0;
}