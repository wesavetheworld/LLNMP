<?php
echo 'phpredis sample:<br />';

$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

echo 'set key:<br />';
echo 'set blog: http://shuang.ca<br />';
echo 'set home: http://llnmp.com<br />';

$redis->set('blog', 'http://shuang.ca');
$redis->set('home', 'http://llnmp.com');

echo 'get key:<br />';

echo 'get blog: ' . $redis->get('blog') . '<br />';
echo 'get home: ' . $redis->get('home') . '<br />';
?>
