class Logger
  @level = :debug

  class << self
    include JsPrimitives
    
    LEVELS = {
      debug: 0,
      info: 1,
      log: 2,
      warn: 3,
      error: 4
    }

    def level=(l)
      @level = l
    end

    def level
      @level
    end

    LEVELS.keys.each do |lev|
      define_method(lev) do |moddule, message|
        if LEVELS[lev] >= LEVELS[level]
          logger.send(lev,
            "#{lev.upcase} --- #{moddule.class} #=> #{message}")
          end
      end
    end
  
    private
  
    def logger
      window[:Stimulus][:logger]
    end
  end
end