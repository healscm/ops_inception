import json
import logging
from django.http import HttpResponse
from rest_framework.response import Response
from libs import gen_ddl, baseview
from libs import util
from core.models import dailytask
from core.task import submit_push_messages
CUSTOM_ERROR = logging.getLogger('ops.core.views')
conf = util.conf_path()
addr_ip = conf.ipaddress

class gen_task(baseview.BaseView):

    '''

    :argument

    :param

    :return 生成的sql语句

    '''

    def post(self, request, args=None):
        try:
            user = request.data['username']
        except KeyError as e:
            CUSTOM_ERROR.error(f'{e.__class__.__name__}: {e}')
            return HttpResponse(status=500)
        else:
            try:
                workId = util.workId()
                dailytask.objects.get_or_create(
                    username=user,
                    date=util.date(),
                    work_id=workId,
                    status=2,
                    task_name=request.data['task_name'],
                    task_type=request.data['task_type'],
                    text=request.data['text'],
                    # bundle_id=id,
                    assigned=request.data['assigned']
                )
                submit_push_messages(
                    workId=workId,
                    user=user,
                    addr_ip=addr_ip,
                    text=request.data['text'],
                    assigned=request.data['assigned'],
                    id=id
                ).start()
                return Response('已提交，请等待管理员审核!')
            except Exception as e:
                CUSTOM_ERROR.error(f'{e.__class__.__name__}: {e}')
                return HttpResponse(status=500)