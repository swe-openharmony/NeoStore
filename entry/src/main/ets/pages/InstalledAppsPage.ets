// ====================================================================
// Page: InstalledAppsPage
// App: NeoStore
// Android baseline:
//   - D:/OH-Appforge/_doc_screenshots_v2/NeoStore/L1_2_installed_populated.png
//   - D:/OH-Appforge/_doc_screenshots_v2/NeoStore/L1_2_installed_populated.xml
// Layout contract:
//   - Top bar: "Installed" title + Search + Sync + Settings icons
//   - Tab row: Installed (selected, filled) | Downloads
//   - Section header "Installed" + "Sort and filter" trailing affordance
//   - App rows: icon tile + name + version (right) + summary
//   - Bottom nav: Latest | Explore | Installed (selected)
// ====================================================================

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MockDataSource } from '../common/MockDataSource';

const TAG = 'InstalledAppsPage';

interface InstalledApp {
  bundleName: string;
  appLabel: string;
  versionName: string;
  summary: string;
  updateAvailable: boolean;
  iconHue: string;
}

interface AppsFile {
  apps: InstalledApp[];
}

type TopTab = 'installed' | 'downloads';
type BottomTab = 'latest' | 'explore' | 'installed';

@Entry
@Component
struct InstalledAppsPage {
  @State private topTab: TopTab = 'installed';
  @State private bottomTab: BottomTab = 'installed';
  @State private apps: InstalledApp[] = [];

  aboutToAppear(): void {
    this.loadApps();
  }

  private async loadApps(): Promise<void> {
    try {
      const data = await MockDataSource.loadJson<AppsFile>(this, 'mock_apps.json');
      this.apps = data.apps;
      hilog.info(0x0000, TAG, 'InstalledAppsPage loaded %{public}d apps from rawfile', this.apps.length);
    } catch (e) {
      hilog.error(0x0000, TAG, 'load failed: %{public}s', String(e));
      this.apps = [];
    }
  }

  private onAppClick(app: InstalledApp): void {
    hilog.info(0x0000, TAG, 'open detail %{public}s', app.bundleName);
  }

  private onSortFilter(): void {
    hilog.info(0x0000, TAG, 'TODO open sort/filter sheet');
  }

  private onSearch(): void {
    hilog.info(0x0000, TAG, 'TODO open search');
  }

  private onSync(): void {
    hilog.info(0x0000, TAG, 'TODO sync repositories');
  }

  private onSettings(): void {
    hilog.info(0x0000, TAG, 'TODO open settings');
  }

  @Builder
  private TopBar() {
    Row() {
      Text('Installed')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F1F1F')
        .layoutWeight(1)
        .margin({ left: 16 });

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('\u{1F50D}').fontSize(18).fontColor('#1F1F1F');
      }
      .width(40).height(40).backgroundColor(Color.Transparent)
      .accessibilityText('Search')
      .onClick(() => this.onSearch());

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('↻').fontSize(20).fontColor('#1F1F1F');
      }
      .width(40).height(40).backgroundColor(Color.Transparent)
      .accessibilityText('Sync repositories')
      .onClick(() => this.onSync());

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('⚙').fontSize(20).fontColor('#1F1F1F');
      }
      .width(40).height(40).backgroundColor(Color.Transparent)
      .margin({ right: 8 })
      .accessibilityText('Settings')
      .onClick(() => this.onSettings());
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private SegmentRow() {
    Row() {
      this.SegmentChip('installed', 'Installed');
      this.SegmentChip('downloads', 'Downloads');
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 12 })
    .justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  private SegmentChip(tab: TopTab, label: string) {
    Row() {
      if (this.topTab === tab) {
        Text('✓').fontSize(14).fontColor('#FFFFFF').margin({ right: 6 });
      }
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.topTab === tab ? '#FFFFFF' : '#1F1F1F');
    }
    .layoutWeight(1)
    .height(40)
    .padding({ left: 16, right: 16 })
    .margin({ left: 4, right: 4 })
    .borderRadius(20)
    .backgroundColor(this.topTab === tab ? '#1976D2' : '#EEEEEE')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.topTab = tab; });
  }

  @Builder
  private SectionHeader() {
    Row() {
      Text('Installed')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F1F1F')
        .layoutWeight(1);

      Row() {
        Text('≡').fontSize(14).fontColor('#1F1F1F');
        Text('Sort and filter')
          .fontSize(14)
          .fontColor('#1F1F1F')
          .margin({ left: 6 });
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(16)
      .backgroundColor('#EFEFEF')
      .onClick(() => this.onSortFilter());
    }
    .width('100%')
    .padding({ left: 24, right: 16, top: 16, bottom: 12 });
  }

  @Builder
  private AppRow(app: InstalledApp) {
    Row() {
      // Icon tile
      Column() {
        Text(app.appLabel.length > 0 ? app.appLabel.charAt(0).toUpperCase() : 'A')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF');
      }
      .width(60)
      .height(60)
      .borderRadius(12)
      .backgroundColor(app.iconHue)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);

      Column() {
        Row() {
          Text(app.appLabel)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F1F1F')
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(app.versionName)
            .fontSize(12)
            .fontColor('#666666')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(8)
            .backgroundColor(app.updateAvailable ? '#FFE0B2' : '#EEEEEE')
            .margin({ left: 8 });
        }
        .width('100%');

        Text(app.summary)
          .fontSize(13)
          .fontColor('#666666')
          .margin({ top: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Top)
    .borderRadius(12)
    .margin({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#FAFAFA')
    .onClick(() => this.onAppClick(app));
  }

  @Builder
  private BottomNav() {
    Row() {
      this.BottomTabItem('latest', '⏱', 'Latest');
      this.BottomTabItem('explore', '\u{1F50E}', 'Explore');
      this.BottomTabItem('installed', '\u{1F4E6}', 'Installed');
    }
    .width('100%')
    .height(64)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  private BottomTabItem(tab: BottomTab, glyph: string, label: string) {
    Column() {
      Text(glyph)
        .fontSize(20)
        .fontColor(this.bottomTab === tab ? '#1976D2' : '#666666');
      Text(label)
        .fontSize(11)
        .fontWeight(this.bottomTab === tab ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.bottomTab === tab ? '#1976D2' : '#666666')
        .margin({ top: 2 });
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.bottomTab === tab ? '#E3F2FD' : Color.Transparent)
    .onClick(() => { this.bottomTab = tab; });
  }

  build() {
    Column() {
      this.TopBar();
      this.SegmentRow();
      this.SectionHeader();

      List() {
        ForEach(this.apps, (app: InstalledApp) => {
          ListItem() {
            this.AppRow(app);
          }
        }, (app: InstalledApp) => app.bundleName);
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto);

      this.BottomNav();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
