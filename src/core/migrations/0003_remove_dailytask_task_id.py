# Generated by Django 2.0.1 on 2018-04-16 08:07

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0002_dailytask'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='dailytask',
            name='task_id',
        ),
    ]
