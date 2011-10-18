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
#include <linux/fs.h>
#include <linux/seq_file.h>
#include <linux/string.h>
#include "symsearch.h"

SYMSEARCH_INIT_FUNCTION(lookup_symbol_address);
EXPORT_SYMBOL(lookup_symbol_address);

/****************************************************/
/* The following must agree with: kernel/kallsyms.h */
/*                                kernel/kallsyms.c */
#define KSYM_NAME_LEN 128

struct kallsym_iter
{
	loff_t pos;
	unsigned long value;
	unsigned int nameoff; /* If iterating in core kernel symbols */
	char type;
	char name[KSYM_NAME_LEN];
	char module_name[MODULE_NAME_LEN];
	int exported;
};
/****************************************************/

/* Find kallsyms_lookup_name as demonstrated here:
   http://www.mail-archive.com/openib-general@openib.org/msg08734.html
 */
static void init_kallsyms_lookup_name(void)
{
	struct file *kallsyms;
	struct seq_file *seq;
	struct kallsym_iter *iter;
	loff_t pos = 0;

	kallsyms = filp_open("/proc/kallsyms", O_RDONLY, 0);
	if (!kallsyms) {
		printk("Failed to open /proc/kallsyms");
		return;
	}

	seq = (struct seq_file *)kallsyms->private_data;
	if (!seq) {
		printk("Failed to fetch sequential file.");
		goto err_close;
	}

	for (iter = seq->op->start(seq, &pos);
	     iter != NULL;
	     iter = seq->op->next(seq, iter, &pos))
	if (!strcmp(iter->name, "kallsyms_lookup_name")) {
		lookup_symbol_address = (lookup_symbol_address_fp)iter->value;
		printk(KERN_INFO "symsearch: Found kallsyms_lookup_name() at %p.", lookup_symbol_address);
		break ;
	}

err_close:
	filp_close(kallsyms, NULL);
}

static int __init 
symsearch_init(void)
{
	init_kallsyms_lookup_name();
	if(!lookup_symbol_address) 
	{
		printk(KERN_INFO "symsearch: could not find kallsyms_lookup_name.\n");
		return -EBUSY;
	}
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
