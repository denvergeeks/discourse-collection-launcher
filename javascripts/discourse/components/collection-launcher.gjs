import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
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

  get expanded() {
    return this.state.isExpanded;
  }

  @action
  toggleInlineSlider() {
    this.state.toggleExpanded();
    document.body.classList.toggle(
      "collections-launcher-expanded",
      this.state.isExpanded
    );
  }

  collapseSlider() {
    this.state.setExpanded(false);
    document.body.classList.remove("collections-launcher-expanded");
  }

  @action
  openNavigatorModal() {
    this.collapseSlider();
    this.state.openModal?.();
  }

  @action
  goPrev() {
    this.collapseSlider();
    this.state.goPrev?.();
  }

  @action
  goNext() {
    this.collapseSlider();
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
          <div
            class="collection-inline-slider-shell"
            data-expanded={{if this.expanded "true" "false"}}
          >
            <div class="collection-inline-slider-track" aria-label="Collection navigation">
              <div class="collection-inline-slider-side collection-inline-slider-side-left">
                {{#if this.state.canGoPrev}}
                  <DButton
                    @action={{this.goPrev}}
                    @translatedLabel={{this.leftLabel}}
                    class="collection-inline-nav collection-inline-nav-prev btn-flat"
                    title={{this.leftLabel}}
                  />
                {{/if}}
              </div>

              <div class="collection-inline-slider-center">
                <button
                  type="button"
                  class="collection-inline-slider-toggle"
                  aria-expanded={{if this.expanded "true" "false"}}
                  aria-label="Toggle collection quick navigator"
                  {{on "click" this.toggleInlineSlider}}
                >
                  <span class="collection-inline-slider-title">
                    {{this.centerLabel}}
                  </span>
                  <span class="collection-inline-slider-meta">
                    {{this.pagerText}}
                  </span>
                </button>
              </div>

              <div class="collection-inline-slider-side collection-inline-slider-side-right">
                {{#if this.state.canGoNext}}
                  <DButton
                    @action={{this.goNext}}
                    @translatedLabel={{this.rightLabel}}
                    class="collection-inline-nav collection-inline-nav-next btn-flat"
                    title={{this.rightLabel}}
                  />
                {{/if}}
              </div>
            </div>

            {{#if settings.show_modal_action}}
              <DButton
                @action={{this.openNavigatorModal}}
                @translatedLabel="Open"
                class="collection-inline-slider-modal-trigger"
                title="Open collection navigator"
              />
            {{/if}}
          </div>
        {{else}}
          <DButton
            @action={{this.openNavigatorModal}}
            @translatedLabel={{concat this.launcherLabel ": " this.centerLabel}}
            class="collection-launcher-button"
          />
        {{/if}}
      </div>
    {{/if}}
  </template>
}
