import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class CollectionLauncher extends Component {
  @service site;

  get isHidden() {
    return settings.launcher_mode === "hidden";
  }

  get isSliderMode() {
    return settings.launcher_mode === "slider";
  }

  get launcherLabel() {
    return settings.launcher_label || "Browse Collection";
  }

  get isMobile() {
    return this.site.mobileView;
  }

  get showOnThisDevice() {
    if (this.isMobile && !settings.enable_mobile_launcher) {
      return false;
    }

    if (!this.isMobile && !settings.enable_desktop_launcher) {
      return false;
    }

    return true;
  }

  get shouldRender() {
    return (
      !this.isHidden &&
      this.showOnThisDevice &&
      this.args.outletArgs?.model &&
      document.querySelector(".discourse-collections-sidebar-panel")
    );
  }

  @action
  toggleInlineSlider() {
    document.body.classList.toggle("collections-launcher-expanded");
  }

  @action
  openNavigatorModal() {
    document
      .querySelector(".collections-nav-toggle")
      ?.dispatchEvent(new MouseEvent("click", { bubbles: true }));
  }

  <template>
    {{#if this.shouldRender}}
      <div
        class="collection-launcher-root"
        data-mode={{if this.isSliderMode "slider" "button"}}
        data-placement={{settings.launcher_placement}}
      >
        {{#if this.isSliderMode}}
          <div class="collection-inline-slider-shell">
            <button
              type="button"
              class="collection-inline-slider-toggle"
              {{on "click" this.toggleInlineSlider}}
            >
              <span class="collection-inline-slider-side collection-inline-slider-side-left">
                Prev
              </span>

              <span class="collection-inline-slider-center">
                {{this.launcherLabel}}
              </span>

              <span class="collection-inline-slider-side collection-inline-slider-side-right">
                Next
              </span>
            </button>

            {{#if settings.show_modal_action}}
              <button
                type="button"
                class="collection-inline-slider-modal-trigger"
                title="Open collection navigator"
                {{on "click" this.openNavigatorModal}}
              >
                Open
              </button>
            {{/if}}
          </div>
        {{else}}
          <button
            type="button"
            class="collection-launcher-button"
            {{on "click" this.openNavigatorModal}}
          >
            {{this.launcherLabel}}
          </button>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
