# encoding: utf-8
module WeixinAuthorize
  module JsTicket
    class Store

      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def self.init_with(client)
        if WeixinAuthorize.jsticket_store_class.present?
          WeixinAuthorize.jsticket_store_class.new(client)
        elsif WeixinAuthorize.weixin_redis.nil?
          ObjectStore.new(client)
        else
          RedisStore.new(client)
        end
      end

      def jsticket_expired?
        raise NotImplementedError, "Subclasses must implement a jsticket_expired? method"
      end

      def refresh_jsticket
        set_jsticket
      end

      def jsticket
        refresh_jsticket if jsticket_expired?
      end

      def set_jsticket
        result = client.http_get("/ticket/getticket", {type: 1}).result
        client.jsticket = result["ticket"]
        client.jsticket_expired_at = WeixinAuthorize.calculate_expire(result["expires_in"])
      end

    end
  end
end
