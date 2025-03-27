"use client";

import { Amplify } from "aws-amplify";
import outputs from "@/amplify_outputs.json";
import { useState } from "react";
import axios from "axios";
import { Button, Form, Input } from "@heroui/react";

Amplify.configure(outputs);

// Axios API
const api = axios.create({
	baseURL: process.env.API_URL,
	withCredentials: true,
});

async function submitQuery(query: string)
{
	if (query === '')
	{
		return (
			{
				status: 'error',
				message: 'Invalid query'
			}
		)
	}

	try 
	{
		// TODO: API call
		// const response = await api.get(`/stock/${query}`);
	
		// TODO: format API call response

		return (
			{
				status: 'success',
				results: [
					// TODO
				]
			}
		)
	} 
	
	catch (e) 
	{
		return (
			{
				status: 'error',
				message: 'Internal error'
			}
		)
	}
}

export default function App() 
{
	const [query, setQuery] = useState('');



	return (
		<main>
			<Form>
				<Input
					label={`Stock Ticker`}
					labelPlacement='inside'
					placeholder={`VTI`}
					type='text'
				/>
				<Button>
					Submit
				</Button>
			</Form>
			<h1>Sample text</h1>
		</main>
	);
}
