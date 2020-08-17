#### 小三峡项目

https://124.152.247.236:4430/portal/#!/service    

Vpn地址：进入下载，下载完成后登录;账密chenn

IFS 地址：http://10.212.184.24:58080/

Svn地址：svn://10.212.184.27/erp_ext  账密：wuyj 

gaox

服务器文件地址：build_home:\\10.212.184.24\Build_APP9UPD2_1014\Build_APP9UPD2  

 账密：administrator  Passw0rd

Forti VPN：账密kongweiyue/Kwydj@528110

数据库配置：

--------------------------------------------------------------------------------

已更至下一个

XSXTrain =(DESCRIPTION = 
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.212.184.19)(PORT = 1521)) 
      (CONNECT_DATA = 
        (SERVER = DEDICATED)
         (SERVICE_NAME = traindb)
    ) 
)

-------------------------------------------------

XSXTrain =  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.212.184.19)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = prod)
    )
  )





新建项目---> 输入build home 地址 从\\开始 \\10.212.184.24\Build_APP9UPD2_1014\Build_APP9UPD2 

均填好后最后harvest项 clear一下   完成

新建项目 选99999999999999999999999999999999999999999999

![image-20200616195516456](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616195516456.png)

安装插件，完成后reset  /update

![image-20200616104433305](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616104433305.png)

登入IFS （小三峡项目需vpn）从IFS Developer 的builde home客户化项目 ，完成后打开项目文件夹

![image-20200616104621405](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616104621405.png)

项目客户化模块vim路径 D:\E\IFS\Xsxtest\workspace\vim

![image-20200616104810869](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616104810869.png)

source文件夹内拷入服务器 项目路径下的 client

服务器项目模块vim 路径：\\10.212.184.24\Build_APP9UPD2_1014\Build_APP9UPD2\source\vim

![image-20200616104959354](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616104959354.png)



如果从SVN更下来，就不用从服务器上拉下来了





![image-20200616102045067](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616102045067.png)

![image-20200616101017172](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101017172.png)

可能会报数据库被锁，则右键clean up 选择Break write locks

![image-20200616101656870](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101656870.png)



![image-20200616101042054](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101042054.png)

确定后重新update

![image-20200616101131427](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101131427.png)



数据库连不上，在Build home中无法客户化时 ，查看build home 路径写对没得

![image-20200616101239533](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101239533.png)

![image-20200616101526845](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101526845.png)

![image-20200616101614444](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101614444.png)

SVN 更新  

![image-20200616101429264](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616101429264.png)

 报错

![image-20200616102611321](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616102611321.png)

再回workspace clean up 然后再update

![image-20200616114126119](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616114126119.png)

project config  中 Build home不要写错



https://www.yiibai.com/plsql/plsql_basic_syntax.html

PL/SQL教程

Oracle 存储过程运算符

![image-20200616131650235](C:\Users\86187\AppData\Roaming\Typora\typora-user-images\image-20200616131650235.png)

**SELECT INTO STATEMENT语句**

可将select到的结果赋值给一个或多个变量

 SELECT student_address INTO 变量1，变量2...

 FROM student where student_grade=100;

游标操作

 Oracle会创建一个存储区域，被称为上下文区域，用于处理SQL语句，其中包含需要处理的语句，例如所有的信息，行数处理，等等。

游标是指向这一上下文的区域。 PL/SQL通过控制光标在上下文区域。游标持有的行(一个或多个)由SQL语句返回。行集合光标保持的被称为活动集合

%FOUND

如果DML语句执行后影响有数据被更新或DQL查到了结果，返回true。否则，返回false。

%NOTFOUND

如果DML语句执行后影响有数据被更新或DQL查到了结果，返回false。否则，返回true。

%ISOPEN

游标打开时返回true，反之，返回false。

%ROWCOUNT

返回DML执行后影响的行数。

使用游标

声明游标定义游标的名称和相关的SELECT语句：

CURSOR 游标名 IS SELECT s_id, s_name FROM student;
打开游标游标分配内存，使得它准备取的SQL语句转换成它返回的行：

OPEN cur_cdd;
抓取游标中的数据，可用LIMIT关键字来限制条数，如果没有默认每次抓取一条：

FETCH cur_cdd INTO id, name ;
关闭游标来释放分配的内存:

CLOSE cur_cdd;

##### 盘江项目

builhome:\\192.168.10.41\QingZhouIFS8

新建项目账密：ifsapp/ifsapp60

服务器账密：

svn://192.168.10.34/ERP_workspace  账密：gaoxiang   gaoxiang

盘江 vpn账密  kongweiyue/Kwydj@528110

盘江数据库

PJ_DEV =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.10.43)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = EEPROD)
    )
  )