#!/system/bin/sh

# Load the module
insmod /system/lib/modules/symsearch.ko

# The module doesn't know the address of kallsyms_lookup_name yet
cat /proc/symsearch/kallsyms_lookup_name

# We can find it via /proc/kallsyms
grep '^........ T kallsyms_lookup_name$' /proc/kallsyms

# Feed it to the module
grep '^........ T kallsyms_lookup_name$' /proc/kallsyms \
    > /proc/symsearch/kallsyms_lookup_name

# Now should match entry in /proc/kallsyms
cat /proc/symsearch/kallsyms_lookup_name
