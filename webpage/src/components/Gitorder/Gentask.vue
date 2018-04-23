<style lang="less">
@import '../../styles/common.less';
@import 'components/table.less';
.demo-spin-icon-load {
    animation: ani-demo-spin 1s linear infinite;
}
</style>
<template>
<div>
  <Row>
    <Card>
      <p slot="title">
        <Icon type="ios-redo"></Icon>
        git任务类型
      </p>
      <div class="edittable-test-con">
        <Form :model="formItem" :label-width="100" ref="taskform" :rules="ruleValidate">
          <FormItem label="任务类型:" prop="task_type">
            <Select v-model="formItem.task_type" placeholder="请选择" >
                <Option v-for="i in dataset" :value="i" :key="i">{{ i }}</Option>
            </Select>
          </FormItem>
          <FormItem label="应用名" prop="task_name">
            <Input v-model="formItem.task_name" placeholder="请输入"></Input>
          </FormItem>
          <FormItem label="备注" prop="text">
            <Input v-model="formItem.text" placeholder="请输入"></Input>
          </FormItem>
          <FormItem label="指定审核人:" prop="assigned">
            <Select v-model="formItem.assigned" filterable transfer>
              <Option v-for="i in assigned" :value="i" :key="i">{{i}}</Option>
            </Select>
          </FormItem>
          <Button type="primary" @click="submit()" style="margin-left: 3%">提交</Button>
        </Form>
        <br>
      </div>
    </Card>
  </Row>
</div>
</template>

<script>
import Cookies from 'js-cookie'
import axios from 'axios'
import util from '../../libs/util'
import edittable from './components/editTable'
import ICol from 'iview/src/components/grid/col'
export default {
  components: {
    ICol,
    edittable,
    editor: require('../../libs/editor')
  },
  data () {
    return {
      dataset: util.task_type,
      item: {},
      basename: [],
      sqlname: [],
      TableDataOld: [],
      TableDataNew: [],
      tableform: {
        sqlname: [],
        basename: [],
        info: []
      },
      Testresults: [],
      putdata: [],
      Add_tmp: {
        Field: '',
        Type: '',
        Null: null,
        Default: null,
        Extra: null,
        Len: '',
        Species: null
      },
      add_row: [],
      username: Cookies.get('user'),
      sql: [],
      openswitch: false,
      pass: false,
      ruleValidate: {
        task_type: [{
          required: true,
          message: '任务类型不得为空',
          trigger: 'change'
        }],
        task_name: [{
          required: true,
          message: '应用名不得为空',
          trigger: 'change'
        }],
        text: [{
            required: true,
            message: '说明不得为空',
            trigger: 'change'
          },
          {
            type: 'string',
            max: 200,
            message: '最多200个字',
            trigger: 'blur'
          }
        ],
        assigned: [{
          required: true,
          message: '审核人不得为空',
          trigger: 'change'
        }]
      },
      formItem: {
        task_type: '',
        task_name: '',
        text: '',
        assigned: ''
      },
      id: null,
      tabs: 'order1',
      assigned: [],
      formDynamic: '',
      validate_gen: true
    }
  },
  methods: {
    editorInit: function () {
      require('brace/mode/mysql')
      require('brace/theme/xcode')
    },
    Connection_Name (index) {
      if (index) {
        this.ScreenConnection(index)
      }
    },
    submit () {
      // console.log(util.url + /gentask/)
      this.$refs['taskform'].validate((valid) => {
        if (valid) {
          console.log('提交测试输出66666')
          axios.post(util.url + '/register/', {
            'task_type': this.formItem.task_type,
            'task_name': this.formItem.task_name,
            'text': this.formItem.text,
            'assigned': this.formItem.assigned,
            'id': this.id[0].id
          })
          console.log('提交测试输出555555')
            .then(res => {
              this.$Notice.success({
                title: res.data
              })
              this.formItem = {
                task_type: '',
                task_name: '',
                text: '',
                assigned: ''
                }
            })
            .catch(() => {
              this.$Notice.error({
                title: '警告',
                desc: '提交测试输出11111'
              })
            })
        }
      })
      // this.$refs['taskform'].validate((valid) => {
      //   if (valid) {
      //     axios.post(util.url + '/gentask/', {
      //       'data': JSON.stringify(this.formItem),
      //       'user': Cookies.get('user'),
      //       'id': this.id[0].id
      //     })
      //       console.log('sss')
      //       .then(res => {
      //         this.$Notice.success({
      //           title: res.data
      //         })
      //         this.formItem = {
      //           task_type: '',
      //           task_name: '',
      //           text: '',
      //           assigned: ''}
      //       })
      //       .then(res => {
      //         this.$Notice.success({
      //           title: '通知',
      //           desc: res.data
      //         })
      //         this.$router.push({
      //           name: 'myorder'
      //         })
      //       })
      //       .catch(() => {
      //         this.$Notice.error({
      //           title: '警告',
      //           desc: '测试生成任务工单报错'
      //         })
      //       })
      //   }
      // })
    },
    ScreenConnection (b) {
      this.tableform.sqlname = this.item.filter(item => {
        if (item.task_type === b) {
          return item
        }
      })
    },
    getdatabases () {
        axios.put(`${util.url}/workorder/connection`, {'permissions_type': 'ddl'})
        .then(res => {
          this.item = res.data['connection']
          this.assigned = res.data['assigend']
        })
        .catch(error => {
          util.ajanxerrorcode(this, error)
        })
    }
  },
  mounted () {
    this.getdatabases()
  }
}
</script>
