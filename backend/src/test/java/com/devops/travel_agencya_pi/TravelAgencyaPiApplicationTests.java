package com.devops.travel_agencya_pi;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

@Import(TestcontainersConfiguration.class)
@SpringBootTest
class TravelAgencyaPiApplicationTests {

	@Test
	void contextLoads() {
	}

}
