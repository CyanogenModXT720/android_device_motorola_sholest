/* 
 * symsearch: - looks up also for unexproted symbols in the kernel
 * exports function:
 *
 * Copyright (C) 2010 Skrilax_CZ
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

#include <linux/proc_fs.h>
#include <linux/string.h>
#include <linux/vmalloc.h>
#include <asm/uaccess.h>

#include "symsearch.h"

#define BUF_SIZE PAGE_SIZE
static char *buf;

static int proc_kallsyms_lookup_name_read(char *buffer, char **buffer_location,
					  off_t offset, int count, int *eof, void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "0x%x\n", (uint)lookup_symbol_address);

	return ret;
}

static int proc_kallsyms_lookup_name_write(struct file *filp, const char __user *buffer,
		unsigned long len, void *data)
{
	uint *address;

	if(!len || len >= BUF_SIZE)
		return -ENOSPC;

	if(copy_from_user(buf, buffer, len))
		return -EFAULT;

	buf[len] = 0;

	if(sscanf(buf, "%x", &address) == 1)
		lookup_symbol_address = (lookup_symbol_address_fp)address;
	else
		printk(KERN_INFO "symsearch: could not read kallsyms_lookup_name address\n");

	return len;
}

SYMSEARCH_INIT_FUNCTION(lookup_symbol_address);
EXPORT_SYMBOL(lookup_symbol_address);

static int __init 
symsearch_init(void)
{
	struct proc_dir_entry *proc_entry;

	buf = (char *)vmalloc(BUF_SIZE);

	proc_mkdir("symsearch", NULL);
	proc_entry = create_proc_read_entry("symsearch/kallsyms_lookup_name", 0644, NULL, proc_kallsyms_lookup_name_read, NULL);
	proc_entry->write_proc = proc_kallsyms_lookup_name_write;

	return 0;
}

static void __exit
symsearch_exit(void)
{
	panic("symsearch is not made to be exited.");
}

module_init(symsearch_init);
module_exit(symsearch_exit);
MODULE_LICENSE("GPL");
