# ------------------------------------------------------------------------------
# ~/_plugins/asciidoctor-extensions/wistia-block.rb
# Asciidoctor extension for Vimeo Video
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
# A block macro that embeds a video from the Vimeo platform
# into the output document
#
# Usage:
#
#   wistia::video_id[theme="vjs_theme_name" role="CSS classes"]
#
# Example:
#
#   .Video title
#   wistia::179528528[theme="city" role="mt-5 mb-5"]
#
# ------------------------------------------------------------------------------
# See:
# https://www.tutorialspoint.com/creating-a-responsive-video-player-using-video-js
# ------------------------------------------------------------------------------

Asciidoctor::Extensions.register do

  class WistiaBlockMacro < Extensions::BlockMacroProcessor
    use_dsl

    named :wistia
    name_positional_attributes 'caption', 'poster', 'theme', 'role'
    default_attrs 'caption' => 'true',
                  'poster' => '/assets/video/poster/wistia/wistia-blue.jpg',
                  'theme' => 'uno',
                  'role' => 'mt-3 mb-3'

    def process parent, target, attributes

      chars           = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
      video_id        = (0...11).map { chars[rand(chars.length)] }.join

      title_html      = (attributes.has_key? 'title') ? %(<div class="video-title">#{attributes['title']}</div>\n) : nil
      poster_image    = (poster = attributes['poster']) ? %(#{poster}) : nil
      theme_name      = (theme = attributes['theme']) ? %(#{theme}) : nil
      caption_enabled = (caption  = attributes['caption'])  ? true : false

      poster_attr     = %(poster="#{poster_image}")
      if attributes['poster'] == 'auto'
        poster_attr = ''
      end

      html = %(
        <div class="wistia-player bottom #{attributes['role']}">
          #{title_html}
          <video
            id="#{video_id}"
            class="video-js vjs-theme-#{theme_name}"
            width="640" height="360"
            #{poster_attr}
            alt="#{attributes['title']}"
            aria-label="#{attributes['title']}"
            data-setup='{
              "fluid" : true,
              "techOrder": [
                "wistia", "html5"
              ],
              "sources": [{
                "type": "video/wistia",
                "src": "#{target}"
              }],
              "wistia": {
                "playback_css_class": "wistia_embed wistia_async_29b0fbf547",
                "autoplay": false
              },
              "controlBar": {
                "pictureInPictureToggle": false,
                "volumePanel": {
                  "inline": false
                }
              }
            }'
          > </video>
        </div>

        <script>
          $(function() {

            function addCaptionAfterImage(imageSrc) {
              const image = document.querySelector(`img[src="${imageSrc}"]`);

              if (image) {
                // create div|caption container
                const newDiv = document.createElement('div');
                newDiv.classList.add('caption');
                newDiv.textContent = '#{attributes['title']}';

                // insert div|caption container AFTER the image
                image.parentNode.insertBefore(newDiv, image.nextSibling);
              } else {
                console.error(`Kein Bild mit src="${imageSrc}" gefunden.`);
              }
            }

            var dependencies_met_page_ready = setInterval (function (options) {
              var pageState      = $('#content').css("display");
              var pageVisible    = (pageState == 'block') ? true : false;
              var j1CoreFinished = (j1.getState() === 'finished') ? true : false;

              if (j1CoreFinished && pageVisible) {
                if ('#{caption_enabled}' === 'true') {
                  addCaptionAfterImage('#{poster_image}');
                }

                clearInterval(dependencies_met_page_ready);
              }
            }, 10);
          });
        </script>
      )

      create_pass_block parent, html, attributes, subs: nil
    end
  end

  block_macro WistiaBlockMacro
end
