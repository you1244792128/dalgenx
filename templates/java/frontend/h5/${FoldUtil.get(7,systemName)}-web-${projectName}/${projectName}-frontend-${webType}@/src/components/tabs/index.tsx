import *  as  React from 'react';
import Link from 'umi/link';

import styles from './index.css';
import {homeInitModel} from "@i/interfaces/HomeFaces";

function styleHandler(selectedIndex, current) {
  return selectedIndex === current ? {background: '#429EE9'} : {};
}

function getStyle(selectedIndex, index) {
  return {
    style: styleHandler(selectedIndex, index),
  }
}

function Footer({selectedIndex}) {
  return (
    <footer className={styles.tabs}>
      <Link to={homeInitModel.pathname}
            className={styles.tabsItem}
            {...getStyle(selectedIndex, 0)}
      >
        <i className={'iconfont icon-shouye'} style={{width: '15px', height: '15px'}}/>
        <span>首页</span>
      </Link>
      <Link to={'abc'}
            className={styles.tabsItem}
            {...getStyle(selectedIndex, 1)}
      >
        <i className={'iconfont icon-shouye'} style={{width: '15px', height: '15px'}}/>
        <span>论坛</span>
      </Link>
      <Link to={'abc'}
            className={styles.tabsItem}
            {...getStyle(selectedIndex, 2)}
      >
        <i className={'iconfont icon-fabu'} style={{width: '15px', height: '15px'}}/>
        <span>发表</span>
      </Link>
      <Link to={'abc'}
            className={styles.tabsItem}
            {...getStyle(selectedIndex, 3)}
      >
        <i className={'iconfont icon-xiaoxi'} style={{width: '15px', height: '15px'}}/>
        <span>消息</span>
      </Link>
      <Link to={'abc'}
            className={styles.tabsItem}
            {...getStyle(selectedIndex, 4)}
      >
        <i className={'iconfont icon-wode'} style={{width: '15px', height: '15px'}}/>
        <span>我的</span>
      </Link>
    </footer>
  );
}

export default Footer;
