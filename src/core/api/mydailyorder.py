import logging
from libs import baseview, util
from django.db.models import Count
from core.models import dailytask
from django.http import HttpResponse
from rest_framework.response import Response

CUSTOM_ERROR = logging.getLogger('ops.core.views')


class dailyorder(baseview.BaseView):

    '''

    :argument 我的工单展示接口api

    '''

    def get(self, request, args: str=None):
        try:
            username = request.GET.get('user')
            page = request.GET.get('page')
            print(username)
            print(page)
        except KeyError as e:
            CUSTOM_ERROR.error(f'{e.__class__.__name__}: {e}')
        else:
            try:
                page_number = dailytask.objects.filter(username=username).aggregate(alter_number=Count('id'))
                start = (int(page) - 1) * 20
                end = int(page) * 20
                info = dailytask.objects.raw(
                    "select core_dailytask.* from core_dailytask \
                    WHERE core_dailytask.username = '%s'ORDER BY core_dailytask.id DESC "
                    % username)[start:end]
                data = util.ser(info)
                return Response({'page': page_number, 'data': data})
            except Exception as e:
                CUSTOM_ERROR.error(f'{e.__class__.__name__}: {e}')
                return HttpResponse(status=500)