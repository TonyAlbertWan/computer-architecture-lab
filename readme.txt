基于原有的多周期CPU实现的五级流水CPU代码过于杂乱无章，并且还有未解决的逻辑连线问题，因此在这里只放能够成功上板的lab1_CPU，并附上测试所用的bit文件。
模块分布如下：
基础的ALU和reg_file模块；
输出控制信号的ControlUnit和switch模块；
在实现load 和 store相关命令所用的readdata和writedata模块；
顶层布线的mycpu_top模块。