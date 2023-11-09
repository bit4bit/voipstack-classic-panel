TARGET=_build/test/lib/voipstack_classic_panel/ebin/voipstack_classic_panel.app

$(TARGET):
	MIX_ENV=test mix do deps.get, deps.compile

.PHONY: lint
lint:
	@echo "#### MIX DIALYZER ####"
	MIX_ENV=test mix dialyzer
	@echo "#### MIX CREDO ####"
	MIX_ENV=test mix credo

compile:
	@echo "#### MIX COMPILE ####"
	MIX_ENV=test mix compile

format:
	@echo "#### MIX FORMAT####"
	MIX_ENV=test mix format

.PHONY: ci
ci: $(TARGET) compile lint format
	@echo "#### MIX TEST ####"
	MIX_ENV=test mix test

.PHONY: coverage
coverage:
	MIX_ENV=test mix test --cover --export-coverage default
	MIX_ENV=test mix test.coverage
