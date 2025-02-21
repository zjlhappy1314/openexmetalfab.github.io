# ------------------------------------------------------------------------------
# ~/_plugins/asciidoctor-extensions/dailymotion-block.rb
# Asciidoctor extension for J1 Dailymotion Video
#
# Product/Info:
# https://jekyll.one
#
# Copyright (C) 2023, 2024 Juergen Adams
#
# J1 Template is licensed under the MIT License.
# See: https://github.com/jekyll-one-org/j1-template/blob/main/LICENSE
# ------------------------------------------------------------------------------
require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
include Asciidoctor

# ------------------------------------------------------------------------------
# A block macro that embeds a video from the Dailymotion platform
# into the output document
#
# Usage:
#
#   dailymotion::video_id[theme="vjs_theme_name" role="CSS classes"]
#
# Example:
#
#   .Video title
#   dailymotion::x87ycik[theme="city" role="mt-5 mb-5"]
#
# ------------------------------------------------------------------------------
# See:
# https://www.tutorialspoint.com/creating-a-responsive-video-player-using-video-js
# ------------------------------------------------------------------------------

Asciidoctor::Extensions.register do

  class DailymotionBlockMacro < Extensions::BlockMacroProcessor
    use_dsl

    named :dailymotion
    name_positional_attributes 'theme', 'role'
    default_attrs 'theme' => 'uno',
                  'role' => 'mt-3 mb-3'

    def process parent, target, attributes

      chars         = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
      video_id      = (0...11).map { chars[rand(chars.length)] }.join

      title_html    = (attributes.has_key? 'title') ? %(<div class="video-title">#{attributes['title']}</div>\n) : nil
      theme_name    = (theme = attributes['theme'])  ? %(#{theme}) : nil

      html = %(
        <div class="dailymotion-player #{attributes['role']}">
          #{title_html}
          <video
            id="#{video_id}"
            class="video-js vjs-theme-#{theme_name}"
            controls
            width="640" height="360"
            aria-label="#{attributes['title']}"
            data-setup='{
              "fluid" : true,
              "techOrder": [
                "dailymotion", "html5"
              ],
              "sources": [{
                "type": "video/dailymotion",
                "src": "//dailymotion.com/video/#{target}"
              }],
              "controlBar": {
                "pictureInPictureToggle": false
              }
            }'
          > </video>
        </div>

        <script>
          $(function() {
            // block all resources NOT required but loaded via 'preload'
            //
            const preloadObserver = new MutationObserver((mutations) => {
              for (const mutation of mutations) {
                if (mutation.type === 'childList' && mutation.target.nodeName === 'LINK') {
                  const link = mutation.target;
                  if (link.rel === 'preload') {
                    // Preload-Prozess unterbrechen
                    link.href = '';
                  }
                }
              }
            });

            var dependencies_met_dm_iframe_loaded = setInterval (function (options) {
              // var pageState      = $('#content').css("display");
              // var pageVisible    = (pageState == 'block') ? true : false;
              // var j1CoreFinished = (j1.getState() === 'finished') ? true : false;
              var DMiframe       = document.querySelector('iframe[id="#{video_id}_dailymotion_api"]');
              var DMiframeLoaded = (DMiframe !== null) ? true : false;

              if (DMiframeLoaded) {
                preloadObserver.observe(DMiframe, {childList: true});
                clearInterval(dependencies_met_dm_iframe_loaded);
              }
            }, 10);
          });
        </script>

      )
      create_pass_block parent, html, attributes, subs: nil
    end
  end

  block_macro DailymotionBlockMacro
end
