### SDK使用方式




    #import "LBTrackerInterface.h"

    - (BOOL)applicationDidFinishLaunch:... 
    {
        [LBTrackerInterface initalizeTrackerWithDelegate:self];
    }

    #pragma mark  - LBTrackerDelegate
    // SDK Usage
    - (void)trackerDidInitialized
    {
        [LBTrackerInterface startTracker];
    }





### 结构

1. 分三个模块 对外接口层(对外接口)、数据中心(数据采集,数据存储/吞吐,本地缓存,内存缓存)、网络访问(HTTP访问)，各模块高聚合 低耦合 便于扩展


### 进度说明

1. 按目前需求,对外接口层和网络访问层完成度90% 数据中心完成度80%
2. Demo无改变  这两天一直在SDK层写代码. 

### 已完成 : 

1. 网络访问模块封装
2. 传感器数据采集, 含 加速度、陀螺仪、磁感应器
3. 设备信息采集, 含 设备唯一ID、连接的WI-FI名、手机型号、手机电量、手机系统版本等
4. SDK架构设计基本确定 
4. SDK接口层基本完成
5. 数据中心层基本完成



### TODO
0. 原有的定位服务有很多问题 重新写一个吧
1. 创建后台回调线程(+runloop),位置和传感器回调在后台线程中执行. 
2. 定时上传、定时重试
3. 数据缓存策略优化
4. 减少DataCenter和HTTPClient的耦合
 





