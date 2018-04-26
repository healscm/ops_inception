<style lang="less">
  @import '../../styles/common.less';
  @import '../Order/components/table.less';
</style>
<template>
  <div>
    <Row>
      <Card>
        <p slot="title">
          <Icon type="person"></Icon>
          查看我的工单
        </p>
        <Row>
          <Col span="24">
          <Table border :columns="columns" :data="table_data" stripe size="small"></Table>
          </Col>
        </Row>
        <br>
        <Page :total="page_number" show-elevator @on-change="currentpage" :page-size="20"></Page>
      </Card>
    </Row>
  </div>
</template>
<script>
  import Cookies from 'js-cookie'
  import axios from 'axios'
  import util from '../../libs/util'
  export default {
    name: 'put',
    data () {
      return {
        columns: [
          {
            title: '工单编号:',
            key: 'work_id',
            sortable: true
          },
          {
            title: '任务名',
            key: 'task_name'
          },
          {
            title: '任务类型',
            key: 'task_type'
          },
          {
            title: '工单说明',
            key: 'text'
          },
          {
            title: '提交时间:',
            key: 'date',
            sortable: true
          },
          {
            title: '提交人',
            key: 'username',
            sortable: true
          },
          {
            title: '状态',
            key: 'status',
            render: (h, params) => {
              const row = params.row
              let color = ''
              let text = ''
              if (row.status === 2) {
                color = 'blue'
                text = '待审核'
              } else if (row.status === 0) {
                color = 'red'
                text = '驳回'
              } else if (row.status === 1) {
                color = 'green'
                text = '已执行'
              } else {
                color = 'yellow'
                text = '执行中'
              }

              return h('Tag', {
                props: {
                  type: 'dot',
                  color: color
                }
              }, text)
            },
            sortable: true,
            filters: [{
              label: '已执行',
              value: 1
            },
              {
                label: '驳回',
                value: 0
              },
              {
                label: '待审核',
                value: 2
              },
              {
                label: '执行中',
                value: 3
              }
            ],
            //            filterMultiple: false 禁止多选,
            filterMethod (value, row) {
              if (value === 1) {
                return row.status === 1
              } else if (value === 0) {
                return row.status === 0
              } else if (value === 2) {
                return row.status === 2
              } else if (value === 3) {
                return row.status === 3
              }
            }
          }
        ],
        page_number: 1,
        computer_room: util.computer_room,
        table_data: []
      }
    },
    methods: {
      currentpage (vl = 1) {
        axios.get(`${util.url}/mydailyorder/?user=${Cookies.get('user')}&page=${vl}`)
          .then(res => {
            this.table_data = res.data.data
            this.page_number = parseInt(res.data.page.alter_number)
          })
          .catch(error => {
            util.ajanxerrorcode(this, error)
          })
      }
    },
    mounted () {
      this.currentpage()
    }
  }
</script>
<!-- remove delete request -->
