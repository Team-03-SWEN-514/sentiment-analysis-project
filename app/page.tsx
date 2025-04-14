"use client";

import { Amplify } from "aws-amplify";
// import outputs from "@/amplify_outputs.json";
import {FormEvent, useState} from "react";
import axios from "axios";
import {Button, CircularProgress, Form, Input, Spinner, Tooltip} from "@heroui/react";

// Amplify.configure(outputs);

// Axios API
const api = axios.create({
	baseURL: process.env.NEXT_PUBLIC_API_URL,
	// withCredentials: true,
	headers: {
		'Content-Type': 'text/json'
	}
});

interface ISentimentScore
{
	Positive: number
	Negative: number
	Mixed: number
	Neutral: number
}

interface ISentiment
{
	Sentiment: string
	SentimentScore: ISentimentScore
}

const submitQuery = async (query: string) =>
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
		const response = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}?ticker=${query}`,
		{
			headers: {
				'Content-Type': 'text/json'
			}
		});

		const data = response.data['sentiment_response'][0] as ISentiment;

		return (
			{
				status: 'success',
				sentiment: data.Sentiment,
				metrics: {
					positive: data.SentimentScore.Positive,
					negative: data.SentimentScore.Negative,
					neutral: data.SentimentScore.Neutral,
					mixed: data.SentimentScore.Mixed,
				}
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

const submitSubscribe = async (email: string) =>
{
    try
    {
        // await api.post(`/subscribe?email=${email}`)
    }

    catch (e)
    {

    }
}

const submitSave = async (query: string, metrics: IMetrics | undefined) =>
{
	if (metrics === undefined)
	{
		throw Error("metrics are not defined")
	}

	await axios.post(`${process.env.NEXT_PUBLIC_API_URL}/db`,
	{
		ticker: query,
		...metrics,
	},
	{
		headers: {
			'Content-Type': 'text/json'
		},
	});
}

const getSavedStocks = async () =>
{
	try
	{
		await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/db`,
		{
			headers: {
				'Content-Type': 'text/json'
			}
		});
	}

	catch (e)
	{

	}
}

function InsetShadowOverlay({className=''}) {
	return (
		<div className={`
			absolute w-full h-full top-0 left-0
			rounded-lg
			pointer-events-none
			${className}
			[box-shadow:_inset_0_0px_4px_rgba(0,0,0,0.4)]
		`}/>
	);
}

const insetSectionBackgroundClassName = `
	bg-lgray-d bg-opacity-50
`;

const insetSectionClassName = `
	rounded-xl
	overflow-clip
	relative
`;

function InsetSection({children, className = '', overlayClassName = ''}: {children?: React.ReactNode, className?: string, overlayClassName?: string}) {
	return (
		<div className={`
			${insetSectionClassName}
			${insetSectionBackgroundClassName}
			${className}
		`}>
			{children}
			<InsetShadowOverlay className={overlayClassName}/>
		</div>
	);
}

interface IMetrics
{
	positive: number
	negative: number
	mixed: number
	neutral: number
}

interface IResult
{
	query: string
	status: string
	message?: string
	sentiment?: string
	metrics?: IMetrics
}

interface IMetricResultColors
{
	indicatorStroke: string
	trackStroke: string
	text: string
}

function MetricResult({metricName, metricValue, colors}: {metricName: string, metricValue?: number, colors: IMetricResultColors})
{
	const resolvedValue = metricValue ?? 0

	return (
		<div className={`flex flex-row place-items-center p-3 gap-3`}>
			<Tooltip content={`${resolvedValue * 100}%`} showArrow={true} placement="bottom">
				<CircularProgress
					size='lg'
					showValueLabel={true}
					value={resolvedValue * 100}
					formatOptions={{style: "decimal", maximumFractionDigits: 1}}
					classNames={{
						svg: "w-16 h-16 drop-shadow-md",
						indicator: colors.indicatorStroke,
						track: colors.trackStroke,
						value: `font-semibold ${colors.text} text-md`,
					}}
					strokeWidth={2}
				/>
			</Tooltip>
			<h3 className={`
				${colors.text}
				font-semibold
				text-2xl
			`}>{metricName}</h3>
		</div>
	)
}

function LoadingContent({loading}: {loading: boolean})
{
	return (
		<div className={`
			w-full h-full
			flex flex-col
			justify-center
			justify-items-center
			${loading ? '' : 'hidden'}
		`}>
			<Spinner size='lg' classNames={
				{
					circle1: 'border-b-red-500',
					circle2: 'border-b-red-500'
				}
			}/>
		</div>
	)
}

function MetricsDisplay({result}: { result: IResult })
{
	return (
		<div className={`
			flex flex-col md:flex-row
			max-w-full
			flex-wrap
		`}>
			<MetricResult
				metricName={`Positive`}
				metricValue={result?.metrics?.positive}
				colors={{
					indicatorStroke: 'stroke-green-700',
					trackStroke: 'stroke-green-700/30',
					text: 'text-green-700'
				}}
			/>
			<MetricResult
				metricName={`Negative`}
				metricValue={result?.metrics?.negative}
				colors={{
					indicatorStroke: 'stroke-red-500',
					trackStroke: 'stroke-red-300',
					text: 'text-red-500'
				}}
			/>
			<MetricResult
				metricName={`Mixed`}
				metricValue={result?.metrics?.mixed}
				colors={{
					indicatorStroke: 'stroke-amber-500',
					trackStroke: 'stroke-amber-500/30',
					text: 'text-amber-500'
				}}
			/>
			<MetricResult
				metricName={`Neutral`}
				metricValue={result?.metrics?.neutral}
				colors={{
					indicatorStroke: 'stroke-gray-500',
					trackStroke: 'stroke-gray-500/30',
					text: 'text-gray-500'
				}}
			/>
		</div>
	)
}

interface IResultsContentProperties
{
	result: IResult
	query: string
	email: string
	setEmail: (value: string) => void
}

function ResultsContent({result, query, email, setEmail}: IResultsContentProperties)
{
	return (
		<div className={`
			w-full h-full
			max-w-full
			
			flex flex-col
			${(result?.sentiment === undefined) ? 'hidden' : ''}
		`}>
			<div className={`
				px-5 pt-4 pb-1
				text-red-500
			`}>
				<h2 className={`
					text-xl font-bold
				`}>Analysis for '{result.query}'</h2>
				<p className={``}>Overall sentiment: {result.sentiment}</p>
			</div>
			<MetricsDisplay result={result}/>
			<div
				className={`
									flex flex-row
									gap-3
									px-3
								`}
			>
				<Input
					label={`Email`}
					labelPlacement='inside'
					placeholder={`Enter your email address...`}
					isClearable={true}
					maxLength={50}
					name={`query`}
					className={`min-h-[3.5rem] rounded-r-none shrink`}
					classNames={{
						inputWrapper: ''
					}}
					value={email}
					onValueChange={setEmail}
					type='email'
				/>
				<Tooltip content={`Receive email notifications about this stock`} showArrow={true} placement="top">
					<Button className={`h-[3.5rem]`} onPress={() => submitSubscribe(email)}>
						Subscribe
					</Button>
				</Tooltip>
				<Tooltip content={`Save this stock`} showArrow={true} placement="top">
					<Button className={`h-[3.5rem]`} onPress={() => submitSave(query, result.metrics)}>
						Save
					</Button>
				</Tooltip>
			</div>
		</div>
	)
}

export default function App()
{
	const [error, setError] = useState('');
	const [query, setQuery] = useState('');
	const [result, setResult] = useState<IResult>({} as IResult);
	const [loading, setLoading] = useState(false);
	const [email, setEmail] = useState('');

	const onSubmit = async (e: FormEvent<HTMLFormElement>) =>
	{
		e.preventDefault()

		setLoading(true)
		setResult({} as IResult)
		setError('')

		const data = Object.fromEntries(new FormData(e.currentTarget)) as { query: string };

		const result = await submitQuery(data.query);

		setLoading(false);
		setResult({
			query: data.query,
			...result
		})

		if (result.status !== 'success')
		{
			setError(result.message ?? '')
		}
	}

	return (
		<main className={`
			w-[100vw]
			h-[100vh]
			bg-stone-800
			overflow-x-hidden
			overflow-y-hidden
			flex flex-col 
			justify-center
			justify-items-center
		`}>
			<p>{process.env.NEXT_PUBLIC_API_URL}</p>
			<div className={`
				mx-5 md:mx-0 md:w-1/2
				self-center
				p-1
				rounded-xl
				flex flex-col gap-1
			`}>
				<h1 className={`font-bold text-gray-100 text-2xl`}>
					Stock Sentiments
				</h1>
				<div className={`flex flex-row gap-1 w-full`}>
					<Form
						onSubmit={onSubmit}
							className={`
							flex flex-row
							grow
							gap-0
							drop-shadow-lg
						`}
					>
						<InsetSection overlayClassName={'rounded-xl'} className={`
							flex flex-row w-full
							gap-0
							bg-opacity-100
							rounded-xl
						`}>
							<Input
								label={`Stock Ticker`}
								labelPlacement='inside'
								placeholder={`Enter a stock ticker...`}
								isClearable={true}
								maxLength={10}
								name={`query`}
								className={`h-[3.5rem] rounded-r-none`}
								classNames={{
									inputWrapper: 'rounded-r-none'
								}}
								value={query}
								onValueChange={setQuery}
								type='text'
							/>
							<Button type={`submit`} className={`
							h-[3.5rem]
							rounded-l-none
							drop-shadow-lg
							bg-red-500
							text-gray-100
							font-medium
						`}>
								Submit
							</Button>
						</InsetSection>
					</Form>
					<InsetSection overlayClassName={'rounded-xl'}>
						<Button type={`submit`} className={`
							h-[3.5rem]
							rounded-l-none
							drop-shadow-lg
							bg-red-500
							text-gray-100
							font-medium
						`}>
							View Saved Stocks
						</Button>
					</InsetSection>
				</div>
				<InsetSection overlayClassName={'rounded-xl'} className={`
					h-[50vh] 
					bg-gray-200
					!bg-opacity-100
				`}>
					<div className={`
						w-full h-full
						overflow-y-auto
						overflow-x-hidden
						relative
					`}>
						<LoadingContent loading={loading}/>
						<ResultsContent email={email} result={result} query={query} setEmail={setEmail}/>
						<div className={`
							w-full h-full
							flex flex-col
							justify-center
							justify-items-center
							text-center
							${error === '' ? 'hidden' : ''}
						`}>
							<p className={`text-red-500 font-bold text-xl`}>{error}</p>
						</div>
					</div>
				</InsetSection>
			</div>
		</main>
	);
}
