package io.github.david2108.travel.agency.api;

import org.springframework.boot.SpringApplication;

public class TestTravelAgencyApiApplication {

	public static void main(String[] args) {
		SpringApplication.from(TravelAgencyApiApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
