#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char path[128];
    sprintf(path, "bytecode/kill.o");

    struct bpf_object *obj;
    struct bpf_link *link = NULL;

    int err = -1;

    // Open eBPF object with the path
    obj = bpf_object__open_file(path, NULL);
    if (libbpf_get_error(obj)) {
        fprintf(stderr, "ERROR: opening BPF object file failed\n");
        return err;
    }

    // Find the program within the obj file
    struct bpf_program *prog = bpf_object__find_program_by_name(obj, "kill_example");
    if (!prog) {
        fprintf(stderr, "ERROR: finding a program with name 'kill_example' failed\n");
        goto cleanup;
    }

    // Load the eBPF object into the kernel
    if (bpf_object__load(obj)) {
        fprintf(stderr, "ERROR: loading BPF object failed\n");
        goto cleanup;
    }

    // Attach the program to the tracepoint
    link = bpf_program__attach(prog);
    if (libbpf_get_error(link)) {
        fprintf(stderr, "ERROR: attaching BPF program failed\n");
        link = NULL;
        goto cleanup;
    }

    err = 0;

    while (1) {
        sleep(1);
    };

    cleanup:
        bpf_link__destroy(link);
        bpf_object__close(obj);

        return err;
}