# frozen_string_literal: true

module TokenAuth
  # A single use human readable token for use with client configuration.
  class ConfigurationToken < ApplicationRecord
    mattr_accessor :valid_period
    self.valid_period = 4.hours
    SAMPLE_SET = %w[ A B C D E F H J K L M N P Q R S T U V W X Y Z
                     2 3 4 5 7 8 9
                     # $ ].freeze
    TOKEN_LENGTH = 6

    validates :expires_at, :entity_id, :value, presence: true
    validates :value, :entity_id, uniqueness: true

    before_validation :set_value, :set_expires_at, on: :create

    # Returns case insensitive match.
    # rubocop:disable Rails/FindBy
    def self.find_match(value)
      return nil unless value.is_a?(String)

      query = value.gsub(/[\s]+/, "")

      return nil unless query.length == TOKEN_LENGTH

      where(arel_table[:expires_at].gt(Time.zone.now))
        .where(arel_table[:value].matches(query))
        .first
    end
    # rubocop:enable Rails/FindBy

    def make_authentication_token(client_uuid:)
      return nil if expired?

      authentication_token = AuthenticationToken
                             .new(entity_id: entity_id,
                                  client_uuid: client_uuid)
      transaction do
        authentication_token.save! && destroy!
      end

      authentication_token
    rescue StandardError
      nil
    end

    def expired?
      Time.zone.now > expires_at
    end

    private

    def set_value
      loop do
        self.value = (0...TOKEN_LENGTH).map { SAMPLE_SET.sample }.join
        break unless self.class.exists?(value: value)
      end
    end

    def set_expires_at
      self.expires_at = Time.zone.now + self.class.valid_period
    end
  end
end
