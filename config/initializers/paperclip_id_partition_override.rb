module Paperclip
  class Attachment
    class << self
      alias_method :original_interpolations, :interpolations
      def interpolations
        original_interpolations.merge(
          :id_partition => lambda do |attachment, style|
            if attachment.instance.id > 46210
              ("%09d" % attachment.instance.id).scan(/\d{3}/).join("/")
            else
              "images/#{attachment.instance.id.to_s}"
            end
          end
        )
      end
    end
  end
end