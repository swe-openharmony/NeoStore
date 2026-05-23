// Page: Index

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'NeoStoreIndex';

interface NavTab {
  id: string;
  label: string;
  glyph: string;
}

@Entry
@Component
struct Index {
  @State private currentTab: string = 'latest';
  @State private bannerVisible: boolean = true;

  private tabs: NavTab[] = [
    { id: 'latest',    label: 'Latest',    glyph: '⚠' },
    { id: 'explore',   label: 'Explore',   glyph: '🧭' },
    { id: 'installed', label: 'Installed', glyph: '🏠' },
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'NeoStore L0 home mounted');
  }

  private onTabTap(tab: NavTab): void {
    this.currentTab = tab.id;
    if (tab.id === 'installed') {
      hilog.info(0x0000, TAG, 'tab → InstalledAppsPage');
      router.pushUrl({ url: 'pages/InstalledAppsPage' });
    } else {
      console.info(`TODO: tab ${tab.id}`);
    }
  }

  @Builder
  private TopBar() {
    Row() {
      Text('Latest').fontSize(22).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
        .layoutWeight(1).margin({ left: 16 });
      Text('🔍').fontSize(20).fontColor('#1F1F1F').width(44).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: search'));
      Text('↻').fontSize(20).fontColor('#1F1F1F').width(44).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: refresh'));
      Text('⚙').fontSize(20).fontColor('#1F1F1F').width(44).height(44).textAlign(TextAlign.Center)
        .onClick(() => console.info('TODO: settings'));
    }
    .width('100%').height(56).alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');
  }

  @Builder
  private Banner() {
    if (this.bannerVisible) {
      Row() {
        Text('⚠').fontSize(20).fontColor('#1F1F1F').margin({ left: 12, right: 12 });
        Text(`Android's openness and F-Droid are threatened by Google. We need your help: https://keepandroidopen.org/`)
          .fontSize(13).fontColor('#1F1F1F').layoutWeight(1);
        Text('✕').fontSize(18).fontColor('#1F1F1F').width(40).height(40).textAlign(TextAlign.Center)
          .onClick(() => { this.bannerVisible = false; });
      }
      .width('92%').padding({ top: 12, bottom: 12 })
      .backgroundColor('#F8DAD8').borderRadius(8)
      .margin({ left: 16, right: 16, top: 12 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => console.info('TODO: open keepandroidopen.org'));
    }
  }

  @Builder
  private ContentCard() {
    Column() {
      // New apps section
      Text('New apps').fontSize(16).fontColor('#1F1F1F')
        .width('100%').padding({ left: 16, top: 16, bottom: 8 });
      Column().width('100%').height(160); // empty body

      // Recently updated section + sort-and-filter pill
      Row() {
        Text('Recently updated').fontSize(16).fontColor('#1F1F1F').layoutWeight(1);
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row() {
            Text('▽').fontSize(14).fontColor('#FFFFFF').margin({ right: 6 });
            Text('Sort and filter').fontSize(13).fontColor('#FFFFFF');
          }
          .alignItems(VerticalAlign.Center);
        }
        .height(36).padding({ left: 16, right: 16 }).backgroundColor('#5C6BC0')
        .onClick(() => console.info('TODO: sort and filter'));
      }
      .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .alignItems(VerticalAlign.Center);

      Column().width('100%').layoutWeight(1); // empty body
    }
    .width('92%')
    .layoutWeight(1)
    .borderColor('#CCCCCC').borderWidth(1).borderRadius(16)
    .margin({ left: 16, right: 16, top: 12, bottom: 12 });
  }

  @Builder
  private BottomNav() {
    Row() {
      ForEach(this.tabs, (tab: NavTab) => {
        Column() {
          if (this.currentTab === tab.id) {
            Text(tab.glyph).fontSize(18).fontColor('#FFFFFF')
              .width(56).height(28).textAlign(TextAlign.Center)
              .backgroundColor('#5C6BC0').borderRadius(14);
          } else {
            Text(tab.glyph).fontSize(18).fontColor('#1F1F1F')
              .width(56).height(28).textAlign(TextAlign.Center);
          }
          Text(tab.label).fontSize(11).fontColor('#1F1F1F').margin({ top: 4 });
        }
        .layoutWeight(1).height(64).justifyContent(FlexAlign.Center)
        .onClick(() => this.onTabTap(tab));
      }, (tab: NavTab) => tab.id);
    }
    .width('100%').height(68).backgroundColor('#FFFFFF');
  }

  build() {
    Column() {
      this.TopBar();
      this.Banner();
      this.ContentCard();
      this.BottomNav();
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF');
  }
}
