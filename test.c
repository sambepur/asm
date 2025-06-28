#include <fcntl.h>
#include <unistd.h>
int main() {
    char buff[200];
    int a = read(open("tta", 00000000), &buff, 200);
    write(1, buff, a);
}