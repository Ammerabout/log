Join =inner join 外键连接，只显示条件相等的数据。

Left join 左表数据和右表条件相等的数据

Right join 右表数据和左表中符合条件的值。

- HashMap底层原理

键值对存储

数组存储[<键，值>]

对key进行计算得出一个hash值，根据hash值对数组长度取模，定位到数组。

- Jdk 1.8对hash算法和寻址算法如何优化

Static final int hash(Object key){
 int h;

Return (key==null)?0:(h=key.hashCode())^(h>>16);

}

某key的hash高低十六位参与运算 右移16位 

与原始值二进制异或运算 得到key 即高16位和低16位异或运算

寻址算法优化： 使用数组长度-1和hash值&运算 即（n-1）&hash 得到数组中的某位置。

数组长度一直是2的n次方 hash对n取模   （n-1）&hash 效果一样，后者效率更高

 

- HashMap 如何解决hash碰撞

 map.put和map.get->算法优化，避免hash冲突做了寻址性能优化

使用数组长度-1&hash值后，可能存在定位位置相同，称为hash碰撞/hash冲突，

解决：在冲突位置生成链表，所有冲突值（key-value）放在链表里，取时使用hash值定位，然后查找链表（遍历）O(n)，数组+链表

优化解决：链表长度增加到一定程度后转换为红黑树，取时使用hash值定位，然后遍历此位置的红黑树O(logn)，数组+链表+红黑树

- HashMap 扩容

数组满后，自动扩容为更大的数组。扩容后rehash，hash值改变，在更大数组的位置不一定相同。

rehash 