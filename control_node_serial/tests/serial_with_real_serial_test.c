#include <gtest/gtest.h>

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#define _POSIX_C_SOURCE  200809L
#include <sys/types.h>
#include <signal.h>


#include <errno.h>
#include <unistd.h> // fork, execvp
#include <time.h>
#include <pthread.h>

#include "serial.c"
char *tty_path = "/tmp/test_serial";


int start_socat()
{
        char *args[] = {"socat", "PTY,link=/tmp/test_serial,raw,echo=0,b500000", "PIPE", NULL};
        int pid = fork();

        if (pid != 0) {
                sleep(1);
                return pid;
        }
        execvp("socat", args);
        perror("");
}


int number_packets = 16;
void *write_data_thread(void *attr)
{
        int fd = *((int * )attr);
        char data[1024];

        data[0] = 0x80;
        data[1] = 0xFF;
        for (int i = 0; i < 256; i++) {
                data[i+2] = i;
        }

        for (int i = 0; i < number_packets; i++) {
                write(fd, data, 256+2);
        }
}
static volatile int received_packets = 0;
void handle_pkt(struct pkt *packet)
{
        received_packets++;
        for (int i = 0; i < packet->len; i++) {
                ASSERT_EQ(i, packet->data[i]);
        }

}


TEST(configure_tty, with_socat)
{
        int socat_pid;
        int serial_fd;
        unsigned char rx_buff[2048];
        pthread_t thread;

        socat_pid = start_socat();
        serial_fd = configure_tty(tty_path);
        pthread_create(&thread, NULL, write_data_thread, &serial_fd);

        // read all packets
        while (received_packets < number_packets) {
            int n_chars = receive_data(serial_fd, rx_buff, 2048, handle_pkt);
            if (n_chars == -1) {
                // Happend when 'socat' didn't run correctly
                // Break to prevent infinite loop
                //
                // Main code does also quits when ret <= 0
                fprintf(stderr, "ABORTING: %s\n", strerror(errno));
                break;
            }
        }
        /* wait for writer thread */
        while (pthread_tryjoin_np(thread, NULL))
            sleep(1);

        ASSERT_EQ(number_packets, received_packets);
        kill(socat_pid, SIGINT);
}

