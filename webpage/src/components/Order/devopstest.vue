<style>
  .div-relative {
    position: relative;
    width: 100%;
  }

  .div-a {
    position: absolute;
    left: 38%;
    top: 30%;
    width: 350px;
    height: 100px
  }
</style>

<template>
  <div id="band" class="edittable-table-height-con">
    <Col span="10">
      <Card>
        <Tabs value="custom">
          <TabPane label="任务" name="custom">
            <Form :model="taskinfo" :label-width="80" ref="userinfova" :rules="userinfoValidate">
              <FormItem label="任务类型:" prop="task_type">
                <Select v-model="taskinfo.task_type" placeholder="请选择" >
                  <Option v-for="i in dataset" :value="i" :key="i">{{ i }}</Option>
                </Select>
              </FormItem>
              <FormItem label="应用名" prop="task_name">
                <Input v-model="taskinfo.task_name" placeholder="请输入"></Input>
              </FormItem>
              <Button type="primary" @click.native="orderswitch" style="margin-left: 8%">提交</Button>
            </Form>
            <br>
          </TabPane>

        </Tabs>
      </Card>
    </Col>
    <Col span="12">
    <Card>
      <p slot="title" class="card-title">
        <Icon type="android-map"></Icon>
        任务栏
      </p>
      <div class="data-sourcefunc-row">
        <H2>说明</H2>
        <br>
        <div class="fuc">
          <H3>主要功能:</H3>
          <H4> 用于git任务的申请（合并、权限、发布）</H4>
        </div>
      </div>
    </Card>
    </Col>
    <Modal v-model="openswitch" @on-ok="Submit" :ok-text="'提交工单'" width="800">
      <Row>
        <Card>
          <div class="step-header-con">
            <h3 style="margin-left: 35%">OPS平台审核工单</h3>
          </div>
          <p class="step-content"></p>
          <Form class="step-form" :label-width="100">
            <FormItem label="用户名:">
              <p>{{username}}</p>
            </FormItem>
            <FormItem label="任务类型:">
              <p>{{taskinfo.task_type}}</p>
            </FormItem>
            <FormItem label="任务名:">
              <p>{{taskinfo.task_name}}</p>
            </FormItem>
            <FormItem label="工单提交说明:" required>
              <Input v-model="taskinfo.text" placeholder="最多不超过50个字"></Input>
            </FormItem>
            <FormItem label="指定审核人:" required>
              <Select v-model="taskinfo.assigned" filterable transfer>
                <Option v-for="i in assigned" :value="i" :key="i">{{i}}</Option>
              </Select>
            </FormItem>
          </Form>
        </Card>
      </Row>
    </Modal>
  </div>
</template>
<script>
  import axios from 'axios'
  import util from '../../libs/util'
  import Cookies from 'js-cookie'
  export default {
    components: {

    },
    name: 'Login',
    data () {
      return {
        dataset: util.task_type,
        taskinfo: {
          username: '',
          task_type: '',
          task_name: '',
          text: '',
          assigned: ''
        },
        assigned: [],
        id: null,
        username: Cookies.get('user'),
        userinfoValidate: {
          task_type: [{
            required: true,
            message: '请输入任务类型',
            trigger: 'blur'
          }],
          task_name: [{
            required: true,
            message: '请输入任务名',
            trigger: 'blur'
          }],
          text: [{
            required: true,
            message: '请输入备注',
            trigger: 'blur'
          }],
          assigned: [{
            required: true,
            message: '请选择审批人',
            trigger: 'blur'
          }]
        },
        // 添加用户遮罩层
        openswitch: false,
        // 更改密码
        editPasswordForm: {
          username: '',
          oldPass: '',
          newPass: '',
          rePass: ''
        },
        // 保存更改密码loding按钮状态
        savePassLoading: false
      }
    },
    methods: {
      Submit () {
        if (this.taskinfo.task_name === '' || this.taskinfo.task_type === '' || this.taskinfo.text === '' || this.taskinfo.assigned === '') {
          this.$Notice.error({
            title: '警告',
            desc: '工单数据缺失,请检查工单信息是否缺失!'
          })
        } else {
          this.$refs['userinfova'].validate((valid) => {
            if (valid) {
              // console.log('this.id[0].id')
              axios.post(util.url + '/gentask/', {
                'username': Cookies.get('user'),
                'task_type': this.taskinfo.task_type,
                'task_name': this.taskinfo.task_name,
                'text': this.taskinfo.text,
                'assigned': this.taskinfo.assigned
                // 'id': this.id[0].id
              })
                .then(res => {
                  this.$Notice.success({
                    title: res.data
                  })
                  // this.refreshuser()
                })
                .catch(() => {
                  this.$Notice.error({
                    title: '警告',
                    desc: '报错啦！'
                  })
                })
              this.addUserModal = false
            }
          })
        }
      },
      orderswitch () {
        this.openswitch = !this.openswitch
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
      window.particlesJS.load('band', '/static/particlesjs-config.json')
    }
  }
</script>
