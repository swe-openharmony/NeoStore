// Page: InstalledAppsPage — installed apps + downloads (4 scenarios)

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MockDataSource } from '../common/MockDataSource';

const TAG = 'InstalledAppsPage';

interface InstalledApp {
  bundleName: string;
  appLabel: string;
  versionName: string;
  newVersion: string;
  summary: string;
  updateAvailable: boolean;
  iconHue: string;
}

interface DownloadItem {
  appLabel: string;
  status: string;
  iconHue: string;
}

interface AppsFile {
  apps: InstalledApp[];
  downloads: DownloadItem[];
}

type TopTab = 'installed' | 'downloads';

@Entry
@Component
struct InstalledAppsPage {
  @State private topTab: TopTab = 'installed';
  @State private apps: InstalledApp[] = [];
  @State private downloads: DownloadItem[] = [];
  @State private sortBy: string = 'Name';
  @State private sortModified: boolean = false;
  @State private sortPanelOpen: boolean = false;
  @State private expandedBundle: string = '';
  @State private favIds: string[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      const data = await MockDataSource.loadJson<AppsFile>(this, 'mock_apps.json');
      this.apps = data.apps;
      this.downloads = data.downloads;
      const stored = AppStorage.get<string>('neostoreFavorite');
      this.favIds = stored ? [stored] : [];
    } catch (e) {
      hilog.error(0x0000, TAG, 'load failed: %{public}s', String(e));
    }
  }

  private sortedApps(): InstalledApp[] {
    const arr = this.apps.slice();
    if (this.sortBy === 'Name') {
      arr.sort((a: InstalledApp, b: InstalledApp) => a.appLabel < b.appLabel ? -1 : (a.appLabel > b.appLabel ? 1 : 0));
    } else {
      // 'Update date' proxy: updatable first
      arr.sort((a: InstalledApp, b: InstalledApp) => (a.updateAvailable === b.updateAvailable ? 0 : (a.updateAvailable ? -1 : 1)));
    }
    return arr;
  }

  private applySort(by: string): void {
    this.sortBy = by;
    this.sortModified = by !== 'Name';
    this.sortPanelOpen = false;
  }

  private toggleFav(bundle: string): void {
    if (this.favIds.includes(bundle)) {
      this.favIds = [];
      AppStorage.delete('neostoreFavorite');
    } else {
      this.favIds = [bundle];
      AppStorage.setOrCreate('neostoreFavorite', bundle);
    }
  }

  private removeDownload(label: string): void {
    this.downloads = this.downloads.filter((item: DownloadItem) => item.appLabel !== label);
  }

  @Builder
  private SegmentRow() {
    Row() {
      this.SegmentChip('installed', 'Installed');
      this.SegmentChip('downloads', 'Downloads');
    }.width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 }).justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  private SegmentChip(tab: TopTab, label: string) {
    Text(label).fontSize(14).fontColor(this.topTab === tab ? '#FFFFFF' : '#1F1F1F')
      .layoutWeight(1).height(36).textAlign(TextAlign.Center).borderRadius(18)
      .backgroundColor(this.topTab === tab ? '#1976D2' : '#EFEFEF').margin({ left: 4, right: 4 })
      .onClick(() => { this.topTab = tab; });
  }

  @Builder
  private AppRow(app: InstalledApp) {
    Column() {
      Row() {
        Column() {
          Text(app.appLabel.length > 0 ? app.appLabel.charAt(0).toUpperCase() : 'A')
            .fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
        }.width(56).height(56).borderRadius(12).backgroundColor(app.iconHue)
          .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);

        Column() {
          Text(app.appLabel).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1F1F1F')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(app.summary).fontSize(13).fontColor('#666666').margin({ top: 4 })
            .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
        }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 14 });

        // Version label — "old → new" when an update exists (场景一 step 3)
        Text(app.updateAvailable ? `${app.versionName} → ${app.newVersion}` : app.versionName)
          .fontSize(12).fontColor(app.updateAvailable ? '#E65100' : '#666666')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(8)
          .backgroundColor(app.updateAvailable ? '#FFE0B2' : '#EEEEEE').margin({ left: 8 });

        Text(this.expandedBundle === app.bundleName ? '▴' : '▾').fontSize(16).fontColor('#888888')
          .padding(8).onClick(() => { this.expandedBundle = this.expandedBundle === app.bundleName ? '' : app.bundleName; });
      }.width('100%').alignItems(VerticalAlign.Top).onClick(() => router.pushUrl({ url: 'pages/AppDetailPage', params: { name: app.appLabel } }));

      // Expanded actions (场景三 step 2-4)
      if (this.expandedBundle === app.bundleName) {
        Row() {
          Text(this.favIds.includes(app.bundleName) ? '♥' : '♡')
            .fontSize(20).fontColor(this.favIds.includes(app.bundleName) ? '#E53935' : '#666666').padding(8)
            .onClick(() => this.toggleFav(app.bundleName));
          Blank().layoutWeight(1);
          Text('Details').fontSize(14).fontColor('#FFFFFF')
            .padding({ left: 20, right: 20, top: 8, bottom: 8 }).borderRadius(16).backgroundColor('#1976D2')
            .onClick(() => router.pushUrl({ url: 'pages/AppDetailPage', params: { name: app.appLabel } }));
        }.width('100%').margin({ top: 12 }).alignItems(VerticalAlign.Center);
      }
    }
    .width('100%').padding(16).borderRadius(12).margin({ left: 8, right: 8, top: 4, bottom: 4 }).backgroundColor('#FAFAFA');
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text('Neo Store').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F1F').layoutWeight(1).margin({ left: 16 });
        }.width('100%').height(56).alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF');

        this.SegmentRow();

        // Section header (title differs per segment)
        Row() {
          Text(this.topTab === 'installed' ? 'Installed applications' : 'Downloads')
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1F1F1F').layoutWeight(1);
          if (this.topTab === 'installed') {
            Row() {
              Text('≡').fontSize(14).fontColor('#1F1F1F');
              Text(this.sortModified ? 'Sort and filter (modified)' : 'Sort and filter').fontSize(14).fontColor('#1F1F1F').margin({ left: 6 });
            }.padding({ left: 12, right: 12, top: 8, bottom: 8 }).borderRadius(16).backgroundColor('#EFEFEF')
              .onClick(() => { this.sortPanelOpen = true; });
          }
        }.width('100%').padding({ left: 24, right: 16, top: 16, bottom: 12 }).alignItems(VerticalAlign.Center);

        if (this.topTab === 'installed') {
          List() {
            ForEach(this.sortedApps(), (app: InstalledApp) => {
              ListItem() { this.AppRow(app); }
            }, (app: InstalledApp) => app.bundleName);
          }.layoutWeight(1).width('100%');
        } else if (this.downloads.length === 0) {
          Column() {
            Text('No downloads').fontSize(16).fontColor('#666666');
          }.layoutWeight(1).width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
        } else {
          List() {
            ForEach(this.downloads, (item: DownloadItem) => {
              ListItem() {
                Row() {
                  Column().width(44).height(44).borderRadius(10).backgroundColor(item.iconHue)
                    .margin({ left: 16, right: 12 });
                  Column() {
                    Text(item.appLabel).fontSize(15).fontColor('#1F1F1F');
                    Text(item.status).fontSize(12).fontColor('#666666').margin({ top: 2 });
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1);
                  Text('Remove').fontSize(14).fontColor('#E53935').padding({ right: 16 })
                    .onClick(() => this.removeDownload(item.appLabel));
                }.width('100%').height(64).alignItems(VerticalAlign.Center);
              }
            }, (item: DownloadItem) => item.appLabel);
          }.layoutWeight(1).width('100%');
        }
      }.width('100%').height('100%').backgroundColor('#FFFFFF');

      if (this.sortPanelOpen) {
        Column() {
          Text('Sort and filter').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1F1F1F').padding(16);
          ForEach(['Name', 'Update date', 'Ascending', 'Descending', 'Repository: Guardian Project',
            'Category', 'License', 'Anti-feature', 'Target SDK', 'Minimum SDK'], (option: string) => {
            Text(option).width('100%').fontSize(15).fontColor('#1F1F1F')
              .padding({ left: 20, right: 20, top: 7, bottom: 7 });
          }, (option: string) => option);
          Text('Close').fontSize(15).fontColor('#1976D2').padding(12).alignSelf(ItemAlign.End)
            .onClick(() => { this.sortPanelOpen = false; });
        }.width(320).backgroundColor('#FFFFFF').borderRadius(12).shadow({ radius: 12, color: '#40000000' });
      }

    }.width('100%').height('100%');
  }
}
