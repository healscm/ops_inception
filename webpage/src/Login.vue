<style>
.div-relative {
  position: relative;
  width: 100%;
}

.div-a {
  position: absolute;
  left: 38%;
  top: 20%;
  width: 350px;
  height: 100px
}
</style>

<template>
<div id="band" class="div-relative">
  <div class="div-a">
    <div style='margin-left: 24%'>
      <Icon type="cube" size="60" style="margin-top:5%"></Icon>
      <p style="margin-left: 24%;margin-top: -16%;font-size: 20px">OPS运维平台</p>
    </div>
    <br>
    <Card>
      <Tabs value="custom">
        <TabPane label="普通登陆" name="custom">
      <Form ref="formInline" :model="formInline" :rules="ruleInline" inline>
        <Form-item prop="user" style="width: 100%">
          <Input v-model="formInline.user" placeholder="Username">
          </Input>
        </Form-item>
        <Form-item prop="password" style="width: 100%">
          <Input type="password" v-model="formInline.password" placeholder="Password" @on-keyup.enter="authdata()">
          </Input>
        </Form-item>
        <Form-item style="width: 100%">
          <Button type="primary" @click="authdata()" style="width: 100%" size="large">登录</Button>
          <p>
            <a style="margin-left: 22%;margin-top: 2%" @click="useraddclick()">注册账号</a>
            <a style="margin-left: 22%;margin-top: 2%" @click="updatepasswdclick()">忘记密码</a>
          </p>
          <p style="margin-left: 22%;margin-top: 2%">使用chrome获得最佳体验</p>
        </Form-item>
      </Form>
        </TabPane>
        <!--<TabPane label="LDAP登陆" name="ldap">-->
          <!--<Form ref="formInline" :model="formInline" :rules="ruleInline" inline>-->
            <!--<Form-item prop="user" style="width: 100%">-->
              <!--<Input v-model="formInline.user" placeholder="ldap_Username">-->
              <!--</Input>-->
            <!--</Form-item>-->
            <!--<Form-item prop="password" style="width: 100%">-->
              <!--<Input type="password" v-model="formInline.password" placeholder="ldap_Password" @on-keyup.enter="authdata()">-->
              <!--</Input>-->
            <!--</Form-item>-->
            <!--<Form-item style="width: 100%">-->
              <!--<Button type="primary" @click="ldap_login()" style="width: 100%" size="large">登录</Button>-->
              <!--<p style="margin-left: 22%;margin-top: 2%">如需注册账号请联系平台管理员</p>-->
              <!--<p style="margin-left: 5%;">2018 © Power By Cookie.Ye 使用chrome获得最佳体验</p>
            <!--</Form-item>-->
          <!--</Form>-->
        <!--</TabPane>-->
      </Tabs>
    </Card>
    <Modal v-model="addUserModal" :closable='false' :mask-closable=false :width="500">
      <h3 slot="header" style="color:#2D8CF0">用户注册</h3>
      <Form :model="userinfo" :label-width="80" ref="userinfova" :rules="userinfoValidate">
        <FormItem label="用户名" prop="username">
          <Input v-model="userinfo.username" placeholder="请输入"></Input>
        </FormItem>
        <FormItem label="密码" prop="password">
          <Input v-model="userinfo.password" placeholder="请输入" type="password"></Input>
        </FormItem>
        <FormItem label="确认密码" prop="confirmpassword">
          <Input v-model="userinfo.confirmpassword" placeholder="请输入" type="password"></Input>
        </FormItem>
        <FormItem label="部门" prop="department">
          <Input v-model="userinfo.department" placeholder="请输入"></Input>
        </FormItem>
        <FormItem label="权限" prop="group">
          <Select v-model="userinfo.group" placeholder="请选择">
            <Option value="guest">使用者</Option>
          </Select>
        </FormItem>
        <FormItem label="电子邮箱" prop="email">
          <Input v-model="userinfo.email" placeholder="请输入"></Input>
        </FormItem>
      </Form>
      <div slot="footer">
        <Button type="text" @click="addUserModal=false">取消</Button>
        <Button type="warning" @click.native="Registered">注册</Button>
      </div>
  </Modal>
  <Modal v-model="editPasswordModal" :closable='false' :mask-closable=false :width="500">
    <h3 slot="header" style="color:#2D8CF0">忘记用户密码</h3>
    <Form ref="editPasswordForm" :model="editPasswordForm" :label-width="100" label-position="right" :rules="passwordValidate">
      <h2>
        请联系运维
      </h2>
    </Form>
    <div slot="footer">
      <Button type="text" @click="cancelEditPass">确定</Button>
      <!--<Button type="primary" @click="saveEditPass" :loading="savePassLoading">保存</Button>-->
    </div>
  </Modal>
  </div>
</div>
</template>
<script>
import axios from 'axios'
import util from './libs/util'
import ICol from '../node_modules/iview/src/components/grid/col.vue'
import Cookies from 'js-cookie'
export default {
  components: {
    ICol
  },
  name: 'Login',
  data () {
    // 添加注册页面函数
    const valideRePassword = (rule, value, callback) => { // eslint-disable-line no-unused-vars
      if (value !== this.editPasswordForm.newPass) {
        callback(new Error('两次输入密码不一致'));
      } else {
        callback();
      }
    };
    const valideuserinfoPassword = (rule, value, callback) => {
      if (value !== this.userinfo.password) {
        callback(new Error('两次输入密码不一致'));
      } else {
        callback();
      }
    };
    return {
      formInline: {
        user: '',
        password: ''
      },
      ruleInline: {
        user: [{
          required: true,
          message: '请填写用户名',
          trigger: 'blur'
        }],
        password: [{
            required: true,
            message: '请填写密码',
            trigger: 'blur'
          },
          {
            type: 'string',
            min: 6,
            message: '密码长度不能小于6位',
            trigger: 'blur'
          }
        ]
      },
      userinfo: {
        username: '',
        password: '',
        confirmpassword: '',
        group: '',
        checkbox: '',
        department: '',
        email: ''
      },
      userinfoValidate: {
        username: [{
          required: true,
          message: '请输入用户名',
          trigger: 'blur'
        }],
        password: [{
          required: true,
          message: '请输入密码',
          trigger: 'blur'
        },
          {
            min: 6,
            message: '请至少输入6个字符',
            trigger: 'blur'
          },
          {
            max: 32,
            message: '最多输入32个字符',
            trigger: 'blur'
          }
        ],
        confirmpassword: [{
          required: true,
          message: '请再次输入新密码',
          trigger: 'blur'
        },
          {
            validator: valideuserinfoPassword,
            trigger: 'blur'
          }
        ],
        group: [{
          required: true,
          message: '请输入权限',
          trigger: 'blur'
        }],
        department: [{
          required: true,
          message: '请输入部门名称',
          trigger: 'blur'
        }],
        email: [{
          required: true,
          message: '请输入邮箱地址',
          trigger: 'blur'
        }]
      },
      // 添加用户遮罩层
      addUserModal: false,
      // 更改密码遮罩层状态
      editPasswordModal: false,
      // 更改密码
      editPasswordForm: {
        username: '',
        oldPass: '',
        newPass: '',
        rePass: ''
      },
      // 保存更改密码loding按钮状态
      savePassLoading: false,
      // 更改密码表单验证规则
      passwordValidate: {
        username: [{
          required: true,
          message: '请输入要修改的用户名',
          trigger: 'blur'
        }],
        oldPass: [{
          required: true,
          message: '请输入原密码',
          trigger: 'blur'
        }],
        newPass: [{
          required: true,
          message: '请输入新密码',
          trigger: 'blur'
        },
          {
            min: 6,
            message: '请至少输入6个字符',
            trigger: 'blur'
          },
          {
            max: 32,
            message: '最多输入32个字符',
            trigger: 'blur'
          }
        ],
        rePass: [{
          required: true,
          message: '请再次输入新密码',
          trigger: 'blur'
        },
          {
            validator: valideRePassword,
            trigger: 'blur'
          }
        ]
      }
    }
  },
  methods: {
    authdata () {
      axios.post(util.auth, {
          'username': this.formInline.user,
          'password': this.formInline.password
        })
        .then(res => {
            axios.defaults.headers.common['Authorization'] = 'JWT ' + res.data['token']
            Cookies.set('user', this.formInline.user)
            Cookies.set('password', this.formInline.password)
            Cookies.set('jwt', 'JWT ' + res.data['token'])
            let auth = res.data['permissions']
            if (auth === 'admin') {
              Cookies.set('access', 0)
            } else {
              Cookies.set('access', 1)
            }
            this.$router.push({
              name: 'home_index'
            })
        })
        .catch(error => {
          util.ajanxerrorcode(this, error)
        })
    },

    useraddclick () {
      this.addUserModal = true;
    },
    updatepasswdclick () {
      this.editPasswordModal = true;
    },
    Registered () {
      this.$refs['userinfova'].validate((valid) => {
        if (valid) {
          axios.post(util.url + '/register/', {
            'username': this.userinfo.username,
            'password': this.userinfo.password,
            'group': this.userinfo.group,
            'department': this.userinfo.department,
            'email': this.userinfo.email
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
                desc: '用户名已注册过,请更换其他用户名注册！'
              })
            })
          this.addUserModal = false
        }
      })
    },
    cancelEditPass () {
      this.editPasswordForm = {}
      this.editPasswordModal = false
    },
    saveEditPass () {
      this.$refs['editPasswordForm'].validate((valid) => {
        if (valid) {
          this.savePassLoading = true;
          axios.put(util.url + '/otheruser/changepwd', {
            'username': this.editPasswordForm.username,
            'new': this.editPasswordForm.newPass,
            'old': this.editPasswordForm.oldPass
          })
            .then(res => {
              this.$Notice.success({
                title: '通知',
                desc: res.data
              })
            })
            .catch(error => {
              util.ajanxerrorcode(this, error)
            })
          this.savePassLoading = false
        }
      });
    },
    ldap_login () {
      axios.post(`${util.url}/ldapauth`, {
        'username': this.formInline.user,
        'password': this.formInline.password
      })
        .then(res => {
          if (res.data['token'] === 'null') {
            this.$Notice.error({
              title: '警告',
              desc: res.data['res']
            })
          } else {
            axios.defaults.headers.common['Authorization'] = 'JWT ' + res.data['token']
            Cookies.set('user', this.formInline.user)
            Cookies.set('password', this.formInline.password)
            Cookies.set('jwt', 'JWT ' + res.data['token'])
            let auth = res.data['permissions']
            if (auth === 'admin') {
              Cookies.set('access', 0)
            } else {
              Cookies.set('access', 1)
            }
            this.$router.push({
              name: 'home_index'
            })
          }
        })
        .catch(error => {
          util.ajanxerrorcode(this, error)
        })
    }
  },
  mounted () {
    window.particlesJS.load('band', '/static/particlesjs-config.json')
  }
}
</script>
