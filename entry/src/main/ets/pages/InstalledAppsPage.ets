// Page: InstalledAppsPage — navigation shell with installed/downloads business logic excised

type TopTab = 'installed' | 'downloads';

@Entry
@Component
struct InstalledAppsPage {
  @State private topTab: TopTab = 'installed';

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

  build() {
    Column() {
      Text('Neo Store')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding(16);
      this.SegmentRow();
      Row() {
        Text(this.topTab === 'installed' ? 'Installed applications' : 'Downloads')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1);
        if (this.topTab === 'installed') {
          Text('Sort and filter').fontSize(14).padding(8);
        }
      }
      .width('100%')
      .padding(16);
      if (this.topTab === 'installed') {
        Text('No installed catalog data')
          .fontSize(16)
          .fontColor('#666666')
          .layoutWeight(1);
      } else {
        Text('Downloads unavailable')
          .fontSize(16)
          .fontColor('#666666')
          .layoutWeight(1);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }
}
