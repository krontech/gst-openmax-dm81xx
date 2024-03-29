/*
 * Copyright (C) 2008-2009 Nokia Corporation.
 *
 * Author: Felipe Contreras <felipe.contreras@nokia.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation
 * version 2.1 of the License.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include <glib.h>

#include "sem.h"

GSem *
g_sem_new (void)
{
    GSem *sem;

    sem = g_new (GSem, 1);
    g_cond_init(&sem->condition);
    g_mutex_init(&sem->mutex);
    sem->counter = 0;

    return sem;
}

GSem *
g_sem_new_with_value (gint value)
{
    GSem *sem;

    sem = g_new (GSem, 1);
    g_cond_init(&sem->condition);
    g_mutex_init(&sem->mutex);
    sem->counter = value;

    return sem;
}

void
g_sem_free (GSem *sem)
{
    g_cond_clear (&sem->condition);
    g_mutex_clear (&sem->mutex);
    g_free (sem);
}

void
g_sem_down (GSem *sem)
{
    g_mutex_lock (&sem->mutex);

    while (sem->counter == 0)
    {
        g_cond_wait (&sem->condition, &sem->mutex);
    }

    sem->counter--;

    g_mutex_unlock (&sem->mutex);
}

void
g_sem_up (GSem *sem)
{
    g_mutex_lock (&sem->mutex);

    sem->counter++;
    g_cond_signal (&sem->condition);

    g_mutex_unlock (&sem->mutex);
}
