module Hotpages::Extensions::Hotwire::TurboHelper
  def turbo_frame_tag(id, **options, &block)
    attributes = { id: id.to_s.tr("_", "-"), **options }
    tag.turbo_frame id:, **attributes, &block
  end
end
