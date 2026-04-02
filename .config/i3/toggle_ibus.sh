#!/bin/bash
ENGINE=$(ibus engine)

if [[ "$ENGINE" == "Bamboo" ]]; then
	ibus engine xkb:us::eng
else
	ibus engine Bamboo
fi
