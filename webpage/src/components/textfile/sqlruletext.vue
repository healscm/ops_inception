<style lang="less">
  @import "../home/home.less";
  @import "../../styles/common.less";
  .fuc {}

  .fuc li {
    margin-top: 2%;
    margin-left: 15%;
  }

  .fuc h4 {
    margin-top: 2%;
    margin-left: 10%;
  }
  .fuc h3 {
  }

</style>

<template lang="html">
  <div class="home-main">
    <Row>
      <Col  class-name="padding-left-5">
      <Row>
      </Row>
      <Row class="margin-top-10">
        <Col >
        <Card>
          <p slot="title" class="card-title">
            <Icon type="android-map"></Icon>
            <a href="qggsqlrule.html"> 数据库规范</a>
          <div v-html="urlsql"></div>
          <!--<sqltext></sqltext>-->
          <a >
          <img class="unlock-avator-img" style="height: 600px; width: auto;" src="../../../static/inception_api.png">
          </a>
          <!--<div class="data-sourcefunc-row">-->
            <!--<div class="fuc">-->
              <!--<H3>使用规则:</H3>-->
              <!--&lt;!&ndash;<H4 v-for="i in board.title" :key="i">{{i}}</H4>&ndash;&gt;-->
              <!--<p>-->
              <!--</p>-->
            <!--</div>-->
          <!--</div>-->
        </Card>
        </Col>
      </Row>
      </Col>
    </Row>
  </div>
</template>

<script>
  // import axios from 'axios'
  // import util from '../../libs/util'
  // import sqltext from '../../components/textfile/qggsqlrule.html';
  import Cookies from 'js-cookie';
  import dataSourcePie from '../home/components/dataSourcePie.vue';
  export default {
    components: {
      dataSourcePie
      // sqltext
    },
    data () {
      return {
        urlsql: '',
        toDoList: [{
          title: ''
        }],
        count: {
          createUser: 0,
          order: 0,
          link: 0,
          dic: 0
        },
        showAddNewTodo: false,
        newToDoItemValue: '',
        username: Cookies.get('user'),
        time: '',
        board: {
          'title': ['1.DML语句生成', '2.数据库字典生成及查看', '3.SQL语句审核及回滚', '4.工单流程化', '5.数据查询', '6.细粒度的权限划分']
        }
      };
    }
    // mounted () {
    //   this.urlsql = '../../components/textfile/qggsqlrule.html'
    // }
    // methods: {
    //   addNewToDoItem () {
    //     this.showAddNewTodo = true;
    //   },
    //   formatDate () {
    //     let date = new Date();
    //     let year = date.getFullYear();
    //     let month = date.getMonth() + 1;
    //     let day = date.getDate();
    //     let hour = date.getHours();
    //     let minute = date.getMinutes();
    //     let second = date.getSeconds();
    //     this.time = year + '/' + month + '/' + day + '  ' + hour + ':' + minute + ':' + second;
    //   },
    //   addNew () {
    //     if (this.newToDoItemValue.length !== 0) {
    //       axios.post(`${util.url}/homedata/todolist/`, {
    //         'username': Cookies.get('user'),
    //         'todo': this.newToDoItemValue
    //       })
    //         .then(() => {
    //           this.toDoList.unshift({
    //             title: this.newToDoItemValue
    //           });
    //           setTimeout(function () {
    //             this.newToDoItemValue = '';
    //           }, 200);
    //           this.showAddNewTodo = false;
    //         })
    //         .catch(error => {
    //           util.ajanxerrorcode(this, error)
    //         })
    //     } else {
    //       this.$Message.error('请输入待办事项内容');
    //     }
    //   },
    //   cancelAdd () {
    //     this.showAddNewTodo = false;
    //     this.newToDoItemValue = '';
    //   },
    //   deltodo (val) {
    //     axios.put(`${util.url}/homedata/deltodo`, {
    //       'username': Cookies.get('user'),
    //       'todo': val
    //     })
    //       .then(() => {
    //         this.gettodo()
    //       })
    //       .catch(error => {
    //         util.ajanxerrorcode(this, error)
    //       })
    //   },
    //   gettodo () {
    //     axios.put(`${util.url}/homedata/todolist`, {
    //       'username': Cookies.get('user')
    //     })
    //       .then(res => {
    //         this.toDoList = res.data
    //       })
    //       .catch(error => {
    //         util.ajanxerrorcode(this, error)
    //       })
    //   }
    // },
    // mounted () {
      // this.urlsql = require('../../components/textfile/qggsqlrule.html')
      // axios.get('../../components/textfile/qggsqlrule.html')
      //   .then(res => {
      //     this.urlsql = res.data
      //   })
      //   .catch(error => {
      //     util.ajanxerrorcode(this, error)
      //   })
    // }
  };
</script>

