"use client";

import "./../app/app.css";
import { Amplify } from "aws-amplify";
import outputs from "@/amplify_outputs.json";
import "@aws-amplify/ui-react/styles.css";

Amplify.configure(outputs);

export default function App() {
	return (
		<main>
			<h1>Sample text</h1>
		</main>
	);
}
