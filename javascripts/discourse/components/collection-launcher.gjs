import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import launcherState from "../lib/collections-launcher-state";

export default class CollectionLauncher extends Component {
  @service site;

  get state() {
    return launcherState;
  }

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
    return !this.isHidden && this.showOnThisDevice && this.state.isReady;
  }

  get centerLabel() {
    return this.state.currentTitle || this.launcherLabel;
  }

  get leftLabel() {
    return this.state.canGoPrev ? this.state.previousTitle : "";
  }

  get rightLabel() {
    return this.state.canGoNext ? this.state.nextTitle : "";
  }

  get pagerText() {
    if (!this.state.totalItems) {
      return "";
    }

    return `${this.state.currentIndex + 1}/${this.state.totalItems}`;
  }

  @action
  toggleInlineSlider() {
    document.body.classList.toggle("collections-launcher-expanded");
  }

  @action
  openNavigatorModal() {
    this.state.openModal?.();
  }

  @action
  goPrev(event) {
    event?.stopPropagation?.();
    this.state.goPrev?.();
  }

  @action
  goNext(event) {
    event?.stopPropagation?.();
    this.state.goNext?.();
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
              <span
                class="collection-inline-slider-side collection-inline-slider-side-left"
              >
                {{#if this.state.canGoPrev}}
                  <button
                    type="button"
                    class="collection-inline-nav collection-inline-nav-prev"
                    {{on "click" this.goPrev}}
                  >
                    {{this.leftLabel}}
                  </button>
                {{/if}}
              </span>

              <span class="collection-inline-slider-center">
                <span class="collection-inline-slider-title">
                  {{this.centerLabel}}
                </span>
                <span class="collection-inline-slider-meta">
                  {{this.pagerText}}
                </span>
              </span>

              <span
                class="collection-inline-slider-side collection-inline-slider-side-right"
              >
                {{#if this.state.canGoNext}}
                  <button
                    type="button"
                    class="collection-inline-nav collection-inline-nav-next"
                    {{on "click" this.goNext}}
                  >
                    {{this.rightLabel}}
                  </button>
                {{/if}}
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
            {{this.launcherLabel}}: {{this.centerLabel}}
          </button>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
